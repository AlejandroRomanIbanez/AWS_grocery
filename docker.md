# Docker Deployment Guide for AWS EC2 and Local Setup

## Introduction

This guide provides instructions for deploying your application with Docker Compose on both AWS EC2 and a local development environment.

---

## Local Deployment

1. **Install Docker and Docker Compose on Your Local Machine**

   - Download and install Docker from [Docker's website](https://www.docker.com/products/docker-desktop).
   - After installation, verify the Docker and Docker Compose installation with:
     ```bash
     docker --version
     docker-compose --version
     ```

2. **Run Docker Compose**

   1. Ensure your .env files are updated to work locally before using docker-compose and you have the build folder updated like you have been doing in previous steps

   2. In your root directory (where the `docker-compose.yml` is located), run:
   ```bash
   docker-compose up -d --build
   ```

3. **Test the app in the browser**
   
   ```bash
   http://localhost:5000
   ```

4. **Stopping the Containers**

   When you want to stop the application:
   ```bash
   docker-compose down
   ```

---

## Deployment on AWS EC2

### 1. Launch an EC2 Instance

   - Launch and connect to the instance via SSH:
     ```bash
     ssh -i /path/to/your-key.pem ec2-user@your-ec2-public-dns
     ```

### 2. Install Docker on EC2

   ```bash
   sudo yum update -y
   sudo yum install -y docker
   sudo service docker start
   sudo usermod -aG docker ec2-user
   ```

   > **Note**: After adding `ec2-user` to the Docker group, log out and back in to avoid `sudo` with Docker commands.

### 3. Install Docker Compose

   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   docker-compose --version
   ```

### 4. Deploy Your Application

   - **Upload Local Build Files to EC2** (if you want to avoid building on EC2):

     From your local machine, copy the most updated `build` folder to EC2, remember to update the .env files correctly before this step:
     ```bash
     scp -i /path/to/your-key.pem -r frontend/build ec2-user@your-ec2-public-dns:/home/ec2-user/your-project-path/frontend/
     ```

   - **Set Environment Variables**:

     Update `.env` files as necessary in both `backend` and `frontend` directories.

   - **Start Docker Compose**:

     In the EC2 instance's project directory:
     ```bash
     docker-compose up -d --build
     ```

   - **Verify Deployment**:

     Visit your instance's public IP with the designated port (e.g., `http://your-ec2-public-ip:5000`).

---

## Troubleshooting

- **Permission Denied**: If you encounter `permission denied` with Docker, ensure that Docker is running and permissions are set:
  ```bash
  sudo chown root:docker /var/run/docker.sock
  sudo chmod 660 /var/run/docker.sock
  sudo systemctl restart docker
  ```

- **CORS Issues**: Ensure your `.env` has correct URLs, especially `REACT_APP_BACKEND_SERVER`.

- **Caching Issues**: If updates don't reflect, clear browser cache or try `docker-compose down --volumes --remove-orphans` and rebuild.
