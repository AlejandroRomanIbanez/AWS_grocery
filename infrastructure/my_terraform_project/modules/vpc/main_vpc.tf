# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc_grocery" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc-grocerymate"
  }
}

# Create the public subnet 1 within the VPC(e.g. eu-central-1a)
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.vpc_grocery.id
  cidr_block              = var.public_subnet_cidr_1
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1-for-grocerymate"
  }
}

# Create the public subnet 2 within the VPC (e.g. eu-central-1b)
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.vpc_grocery.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet2-for-grocerymate"
  }
}

# Create private subnet 1
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.vpc_grocery.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1"
  }
}

# Create private subnet 2
resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.vpc_grocery.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_grocery.id
  tags = {
    Name = "main-igw-grocerymate"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_grocery.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table-grocerymate"
  }
}

# Associate public subnet 1 with public route table
resource "aws_route_table_association" "public_assoc1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

# Associate public subnet 2 with public route table
resource "aws_route_table_association" "public_assoc2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
####### for the next Steps I need from Admin right ec2:AllocateAddress because:
#Error: UnauthorizedOperation: You are not authorized to perform: ec2:AllocateAddress

# Create Elastic IP for NAT Gateway
# resource "aws_eip" "nat_eip" {
#  tags = {
#    Name = "nat-eip"
#  }
#}

# Create NAT Gateway in public subnet 1 (need from Admin right ec2:AllocateAddress)
#resource "aws_nat_gateway" "nat" {
  #allocation_id = aws_eip.nat_eip.id
  #subnet_id     = aws_subnet.public1.id

  #tags = {
    #Name = "nat-gateway"
 # }

 # depends_on = [aws_internet_gateway.igw]
#}

# Create route table for private subnets (need from Admin right ec2:AllocateAddress)
#resource "aws_route_table" "private" {
  #vpc_id = aws_vpc.vpc_grocery.id

  #route {
    #cidr_block     = "0.0.0.0/0"
    #nat_gateway_id = aws_nat_gateway.nat.id
  #}

  #tags = {
    #Name = "private-route-table-grocerymate"
  #}
#}

# Associate private subnet 1 with private route table
#resource "aws_route_table_association" "private1_assoc" {
  #subnet_id      = aws_subnet.private1.id
  #route_table_id = aws_route_table.private.id
#}

# Associate private subnet 2 with private route table
#resource "aws_route_table_association" "private2_assoc" {
  #subnet_id      = aws_subnet.private2.id
  #route_table_id = aws_route_table.private.id
#}
