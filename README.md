# 🛒 Deployment Guide: GroceryMate AWS Infrastructure

A lightweight, Terraform-based AWS infrastructure for deploying a containerized Flask application, designed as an MVP with scalability and production-readiness in mind.

## 📖 Table of Contents

- [Introduction](#1-introduction)

- [Architecture Diagram](#2-architecture-diagram)

- [Infrastructure Overview](#3-infrastructure-overview)

- [Folder Structure](#4-folder-structure)

- [Key Features](#5-key-features)

- [AWS Services Used](#6-aws-services-used)

- [Monitoring & Alerts](#7-monitoring--alerts)

- [Cost Management & FinOps](#8-cost-management--finops)

- [How to Deploy](#9-how-to-deploy)

- [Future Enhancements](#10-future-enhancements)

---

## 1. Introduction

This project is part of the Cloud Track in our Software Engineering bootcamp at Masterschool. The application was originally developed by Alejandro Román, our Track Mentor. Thanks to him for providing the base application.
Our task was to design and deploy its AWS infrastructure step by step, implementing each component individually using Terraform. While there are currently a few manual configuration steps, they are scheduled to be replaced with automated IaC code in the next iteration.

For details about the application's features and local installation, refer to the original `App.md`. This document focuses exclusively on the AWS infrastructure, deployment process, and automation.

---

## 2. Architecture Diagram

### 🏗️ **System Architecture**

![GroceryMate AWS Architecture](./infrastructure/images/architecture_diagram.png)


This project deploys a containerized Flask application on AWS using Terraform. It features a secure VPC, RDS PostgreSQL database, and a fully automated monitoring loop using CloudWatch Alarms and SNS notifications.

This architecture is intentionally designed as an MVP to prioritize simplicity, cost-efficiency, and fast iteration.

It remains easily extensible to a production-grade setup.

---

## 3. Infrastructure Overview

### 🏗️ GroceryMate Infrastructure (AWS & Terraform)

This project uses **Infrastructure as Code (IaC)** to deploy the GroceryMate application to AWS.

It automates the setup of the network, compute, database, and monitoring layers.

### 🛠️ Tech Stack & Ports

| Service | Tool/Engine | Port | Purpose |
| :--- | :--- | :--- | :--- |
| **Frontend/API** | Flask (Python) | 5000 | Application Logic |
| **Container** | Docker | N/A | Environment Isolation |
| **Database** | PostgreSQL 16 | 5432 | Persistent Data Storage |
| **IaC** | Terraform | N/A | Infrastructure Automation |
| **Security** | IAM Roles | N/A | Least Privilege Access |

---

## 4. Folder Structure

```bash
infrastructure/
├── images/             # Architecture diagrams and screenshots
│   └── architecture_diagram.png
├── scripts/            # Shell scripts & Cloud-init (User Data)
│   └── docker_setup.tftpl
├── main.tf             # Primary AWS Resource definitions
├── providers.tf        # Terraform & AWS Provider config (S3 Backend)
├── terraform.tfvars    # Environment variables (Sensitive)
└── variables.tf        # Variable definitions
```

---

## 5. 🚀 Key Features

- **MVP-first Design:** Built for simplicity and cost-efficiency, with a clear upgrade path to production architecture

- **Remote State:** Terraform state is stored in S3 (`grocerymate-tf-state-gajanan-x12`) for security and collaboration

- **Containerized Deployment:** Flask app runs in Docker on EC2 via `user_data`

- **Automated Database Setup:** RDS PostgreSQL schema initialized during deployment

---

## 6. 📊 AWS Services Used

- EC2 (t3.micro): Hosts the application

- RDS (PostgreSQL 16): Managed database

- S3: Stores avatars and Terraform state

- IAM: Secure access without hardcoded credentials

- CloudWatch & SNS: Monitoring and alerting

---

## 7. 🛡️ Monitoring & Alerts

- **High CPU Alarm:** Triggers if EC2 CPU > 80% for 4 minutes

- **Low Storage Alarm:** Triggers if RDS free space < 1GB

- **S3 Error Alarm:** Detects 4xx errors

- **Billing Alarm:** Set at $30 USD

---

## 8. 💰 Cost Management & FinOps

To ensure financial accountability, I integrated **Infracost** into my local development workflow. This allowed me to:

- **Estimate Costs Pre-Deployment:** I generated a cost breakdown of the `main.tf` before applying changes.

- **Identify Cost Drivers:** Quickly saw that the RDS instance and NAT Gateways (if used) are the primary cost factors.

- **Budget Alignment:** Verified that the current architecture fits within the AWS Free Tier, maintaining a projected monthly cost of near $0.00 for the first year.


> **Pro-Tip:** I used `infracost breakdown --path .` to verify that my move from a standard instance to a `t3.micro`
> was the most cost-effective choice for this MVP.

---

## 9. 🛠️ How to Deploy

- Ensure your AWS credentials are configured with the correct IAM permissions.

- Initialize Terraform:

```bash

terraform init

```

- Analyze & Deploy:

```bash

terraform plan

infracost breakdown --path . # Review costs before committing

terraform apply # Deploy the full stack

```

### Maintenance & Cleanup

**Targeted Refresh:**

```bash

terraform apply -replace="aws_instance.web" # Recreates only the EC2 instance to test user data

```

**Full Teardown:**

```bash

terraform destroy # Removes all AWS resources

```

---

## 10. Future Enhancements

- Migrate Docker images to AWS ECR

- Use AWS SSM Parameter Store for secrets

- Add Application Load Balancer (ALB) for scalability and SSL

---
