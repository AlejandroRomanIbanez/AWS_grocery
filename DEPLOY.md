# Deploying an Application on an Existing EC2 Instance

This guide will help you deploy an application on an existing EC2 instance running Amazon Linux. The app requires Python3, PostgreSQL, Node.js, NPM, and Git.

## Prerequisites

- Ensure your EC2 instance is set up and running.
- You have the .pem key to access your EC2 instance.
- You know the public IP of your EC2 instance.

## Step 1: Connect to Your EC2 Instance

Open your terminal and use SSH to connect to your EC2 instance:

```bash
ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-ip
```
## Step 2: Update Your EC2 Instance
Before installing any software, it’s a good practice to update your instance:

```bash
sudo yum update -y
```

## Step 3: Install Git
Git is essential for pulling your app from a repository (like GitHub):
```bash
sudo yum install git -y
Verify the installation:
```
```bash
git --version
```

## Step 4: Install Python3
To install Python3 on Amazon Linux:

```bash
sudo yum install python3 -y
```

Verify the installation:
```bash
python3 --version
```

## Step 5: Install PostgreSQL 15 (Server and Client)
Run the following command to install PostgreSQL 15:

```bash
sudo dnf install postgresql15 postgresql15-server postgresql15-contrib -y
```
## Step 6: Install Node.js and NPM
```bash
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs
```

Verify the installation:
```bash
node -v
npm -v
```
## Step 7 : Follow the README.md instructions to install the app(Omit build in EC2 and follow step 8)
Follow the instruction of readme to install and set up everything like your did in local, skipping build there to save time and resources, and now doing it inside EC2

## Step 8: Transfer Your App's Build Files (Optional)
After follow the app steps, use scp to copy your frontend build files to your EC2 instance. This makes deployment quicker:

```bash
scp -i "/path/to/your-key.pem" -r /path/to/local/build ec2-user@your-ec2-public-ip:/path/to/ec2/directory/
```

For example:

```bash
scp -i "grocery.pem" -r C:\Users\entse\Desktop\AWS_grocery\GroceryMate\frontend\build ec2-user@52.59.7.20:/home/ec2-user/AWS_grocery/frontend/
```

Verify the files are transferred by using:
```bash
ls /home/ec2-user/AWS_grocery/frontend/
```

Step 8: Configure Security Groups for Flask (Port 5000)
To allow Flask to work on port 5000, configure inbound rules in your AWS security group:

Navigate to Security > Security Groups > Inbound Rules.
Add a new custom TCP inbound rule for port 5000 with the correct protocol and source (e.g., your IP or public access).

## Step 9: Automate App Running with Scheduled Tasks (Optional)
You can schedule when your app starts and stops to save AWS resources. Use the following commands:

First install this:
```bash
sudo yum install cronie -y
```
After installing, you need to start and enable the cron service:
```bash
sudo service crond start
sudo chkconfig crond on
```
To check if the cron service is running:
```bash
sudo service crond status
```
Now that cron is installed and running, you can edit the crontab file:
```bash
crontab -e
```
Then add this next lines inside to add your start and stop commands to the crontab file:

- Start the app at 7:00 AM UTC:
```bash
0 7 * * * source ~/AWS_grocery/backend/venv/bin/activate && cd ~/AWS_grocery/backend && nohup python run.py > ~/AWS_grocery/backend/app.log 2>&1 &
```

- Stop the app at 7:00 PM UTC:
```bash
0 19 * * * pkill -f 'python run.py'
```

Go to your ip in the browser to check if you app is public now:
```bash
http://instance-ip:5000
```