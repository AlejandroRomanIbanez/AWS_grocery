# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr                     # CIDR block for the VPC (e.g., "10.0.0.0/16")
  enable_dns_support   = true                   # Enable DNS resolution within the VPC
  enable_dns_hostnames = true                   # Enable DNS hostnames for instances
  tags = {
    Name = "GroceryVPC"                         # Tag for easy identification in AWS Console
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id                      # Attach the IGW to the VPC
  tags = {
    Name = "GroceryIGW"                         # Tag for identification
  }
}

# Public Subnets (for ALB)
resource "aws_subnet" "public" {
  count             = 2                         # Create 2 public subnets for high availability
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)  # Subdivide VPC CIDR (e.g., "10.0.0.0/24", "10.0.1.0/24")
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
  map_public_ip_on_launch = true                # Automatically assign public IPs to instances in these subnets
  tags = {
    Name = "PublicSubnet-${count.index}"        # Unique name for each subnet (e.g., PublicSubnet-0)
  }
}

# Private Subnets (for EC2 instances and RDS)
resource "aws_subnet" "private" {
  count             = 2                         # Create 2 private subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 2)  # Subdivide VPC CIDR (e.g., "10.0.2.0/24", "10.0.3.0/24")
  availability_zone = element(data.aws_availability_zones.available.names, count.index)  # Spread across AZs
  tags = {
    Name = "PrivateSubnet-${count.index}"       # Unique name for each subnet (e.g., PrivateSubnet-0)
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"  # Updated to use the modern 'domain' attribute instead of deprecated 'vpc'
}

# NAT Gateway for private subnets (outbound internet access)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id            # Associate the Elastic IP with the NAT Gateway
  subnet_id     = aws_subnet.public[0].id       # Place the NAT Gateway in the first public subnet
  tags = {
    Name = "GroceryNATGateway"                  # Tag for identification
  }
}

# Public Route Table (for public subnets)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id                      # Associate with the VPC
  route {
    cidr_block = "0.0.0.0/0"                    # Route all outbound traffic to the Internet Gateway
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"                   # Tag for identification
  }
}

# Private Route Table (for private subnets)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id                      # Associate with the VPC
  route {
    cidr_block = "0.0.0.0/0"                    # Route all outbound traffic to the NAT Gateway
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "PrivateRouteTable"                  # Tag for identification
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Group for the ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"            # Unique name for the security group
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80                            # Allow inbound HTTP traffic
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]                 # Allow from anywhere (restrict in production)
  }

  egress {
    from_port   = 0                             # Allow all outbound traffic
    to_port     = 0
    protocol    = "-1"                          # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source to get available AZs in the region
data "aws_availability_zones" "available" {}
