#!/bin/bash

# Update the system (Amazon Linux 2023 uses dnf)
sudo dnf update -y

# Install Docker
sudo dnf install -y docker

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group (so you can use Docker without sudo)
sudo usermod -aG docker ec2-user

# Clone your app repository
cd /home/ec2-user
git clone https://github.com/chris1837-prog/AWS_Grocery_App.git

# Build Docker image from the repo
cd AWS_Grocery_App
sudo docker build -t grocery-app .

# Run the container (on port 80)
sudo docker run -d -p 80:80 grocery-app
