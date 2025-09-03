# Configure the AWS provider for the Frankfurt region
provider "aws" {
  region = "eu-central-1"
}

# IAM module to create an IAM role and instance profile for EC2
module "iam" {
  source = "./modules/IAM"
}

# Generate a random suffix to ensure the S3 bucket name is globally unique
resource "random_id" "bucket_id" {
  byte_length = 4
}

# VPC module to create VPC, public/private subnets, and networking components
module "vpc" {
  source                 = "./modules/vpc"
  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidr_1   = "10.0.1.0/24"
  public_subnet_cidr_2   = "10.0.2.0/24"
  availability_zone_1    = "eu-central-1a"
  availability_zone_2    = "eu-central-1b"
}

# EC2 module to launch a single EC2 instance for the GroceryMate app
module "webserver" {
  source                 = "./modules/ec2"
  vpc_id                 = module.vpc.vpc_id
  public_subnet_id       = module.vpc.public_subnet_ids[0] # Fix: pick first subnet
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data_script       = file("scripts/install_docker.sh")
  public_key_path        = var.public_key_path
  iam_instance_profile   = module.iam.ec2_instance_profile_name
}

# ALB and ASG module to launch multiple EC2 instances behind a Load Balancer
module "alb_asg" {
  source                = "./modules/ALB_ASG"
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  user_data_script      = file("scripts/install_docker.sh")
  ec2_security_group_id = module.webserver.web_sg_id
}

# RDS module to provision a PostgreSQL database in private subnets
module "rds" {
  source              = "./modules/RDS"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  db_password         = var.db_password
  ec2_sg_id           = module.webserver.web_sg_id
}

# S3 module to create a globally unique bucket for storing app data or backups
module "s3" {
  source      = "./modules/S3-Bucket"
  bucket_name = "grocerymate-${random_id.bucket_id.hex}"
}

# Lambda module to create a health-check Lambda function for the ALB
module "lambda" {
  source         = "./modules/lambda"

  alb_dns_name   = module.alb_asg.alb_dns_name
}


