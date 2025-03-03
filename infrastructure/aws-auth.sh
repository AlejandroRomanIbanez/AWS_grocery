#!/bin/bash

# AWS Account ID
AWS_ACCOUNT_ID="324037288022"

# AWS SSO Profile Name (from ~/.aws/config)
AWS_SSO_PROFILE="324037288022_AdministratorAccess"

# Terraform Execution Role
TERRAFORM_ROLE_ARN="arn:aws:iam::324037288022:role/TerraformExecutionRole"

# Role Session Name
SESSION_NAME="TerraformSession"

# STS Duration (Max 12 hours = 43200 seconds, defaulting to 1 hour)
STS_DURATION=3600

echo "🔐 Checking AWS authentication..."

# Step 1: Check if the current AWS session is valid
aws sts get-caller-identity &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "🔄 AWS SSO session expired. Logging in with MFA prompt (if enabled)..."
    aws sso login --profile "$AWS_SSO_PROFILE" --no-browser || {
        echo "❌ SSO login failed. Please manually log in via browser and provide MFA if prompted."
        echo "Open this URL in your browser if needed:"
        echo "https://masterschool.awsapps.com/start/#"
        exit 1
    }

    echo "✅ SSO login successful. Retrieving new credentials..."
fi

# Step 2: Retrieve fresh credentials from AWS SSO
echo "🔄 Retrieving SSO credentials..."
ACCESS_TOKEN_FILE=$(ls -t ~/.aws/sso/cache/ | head -n 1)
if [[ ! -f ~/.aws/sso/cache/$ACCESS_TOKEN_FILE ]]; then
    echo "❌ No SSO token found. Please log in again."
    exit 1
fi

ACCESS_TOKEN=$(cat ~/.aws/sso/cache/$ACCESS_TOKEN_FILE | jq -r .accessToken)
if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
    echo "❌ Failed to retrieve AWS SSO access token. Logging in again..."
    aws sso login --profile "$AWS_SSO_PROFILE" --no-browser
    ACCESS_TOKEN=$(cat ~/.aws/sso/cache/$(ls -t ~/.aws/sso/cache/ | head -n 1) | jq -r .accessToken)
fi

ROLE_CREDENTIALS=$(aws sso get-role-credentials --account-id "$AWS_ACCOUNT_ID" --role-name "AdministratorAccess" \
    --access-token "$ACCESS_TOKEN" --output json 2>/dev/null || echo "error")

if [[ "$ROLE_CREDENTIALS" == "error" ]]; then
    echo "❌ Failed to retrieve SSO credentials. Please ensure MFA is enabled or adjust trust policy if testing."
    exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "$ROLE_CREDENTIALS" | jq -r '.roleCredentials.accessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$ROLE_CREDENTIALS" | jq -r '.roleCredentials.secretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$ROLE_CREDENTIALS" | jq -r '.roleCredentials.sessionToken')

echo "🔐 AWS SSO authentication successful."

# Step 3: Validate AWS Credentials Before Assuming Role
aws sts get-caller-identity &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "❌ AWS credentials invalid. Exiting..."
    exit 1
fi

# Step 4: Assume the Terraform Execution Role
echo "🔄 Assuming Terraform Execution Role..."
ASSUMED_ROLE=$(aws sts assume-role --role-arn "$TERRAFORM_ROLE_ARN" --role-session-name "$SESSION_NAME" --duration-seconds "$STS_DURATION" --output json 2>/dev/null || echo "error")

if [[ "$ASSUMED_ROLE" == "error" ]]; then
    echo "❌ Failed to assume Terraform Execution Role. Possible causes:"
    echo "  - MFA not enabled or provided for SSO user 'Student01.25-DanielSiebert'."
    echo "  - SSO permission set 'AWSReservedSSO_AdministratorAccess_85c7c2077ee14413' lacks sts:AssumeRoleWithSAML for '$TERRAFORM_ROLE_ARN'."
    echo "  - Trust policy for '$TERRAFORM_ROLE_ARN' may need adjustment (e.g., incorrect SAML:sub or missing MFA condition)."
    echo "Please enable MFA in AWS SSO, update SSO permissions, or temporarily adjust the trust policy for testing (reintroduce MFA later)."
    exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "$ASSUMED_ROLE" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$ASSUMED_ROLE" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$ASSUMED_ROLE" | jq -r '.Credentials.SessionToken')
export AWS_SESSION_EXPIRATION=$(echo "$ASSUMED_ROLE" | jq -r '.Credentials.Expiration')

echo "✅ Terraform Execution Role assumed successfully."
aws sts get-caller-identity
