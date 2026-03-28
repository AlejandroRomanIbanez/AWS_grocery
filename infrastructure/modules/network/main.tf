# 1.1 Create the Custom VPC
resource "aws_vpc" "grocerymate_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "grocerymate-vpc" }
}

# 1.2 Create an Internet Gateway (So EC2 can reach the internet)

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.grocerymate_vpc.id
  tags   = { Name = "grocerymate-igw" }
}

# 1.3 Public Subnet (For EC2)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.grocerymate_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"
  tags = { Name = "grocerymate-public-1" }
}

# 1.4 Private Subnets (For RDS - Needs 2 for AWS High Availability standards)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.grocerymate_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"
  tags = { Name = "grocerymate-private-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.grocerymate_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1b"
  tags = { Name = "grocerymate-private-2" }
}

# 1.5 Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.grocerymate_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}