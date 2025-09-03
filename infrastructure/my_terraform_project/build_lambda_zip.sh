#!/bin/bash

# Step 1: Create the build directory if it doesn't exist
mkdir -p build

# Step 2: Copy the rendered Python file from Terraform template to build folder
# Rename it to match the expected Lambda handler file (lambda_function.py)
cp modules/lambda/lambda_health_check_probe.py build/lambda_function.py

# Step 3: Zip the Lambda function file
cd build
zip lambda.zip lambda_function.py

# Step 4: Clean up the temporary copied file (optional)
rm lambda_function.py

# Step 5: Notify the user
echo "✅ Lambda code successfully zipped to build/lambda.zip"
