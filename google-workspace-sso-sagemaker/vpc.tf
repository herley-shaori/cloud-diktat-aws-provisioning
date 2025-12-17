# VPC for SageMaker Domain
resource "aws_vpc" "sagemaker" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "sagemaker-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "sagemaker" {
  vpc_id = aws_vpc.sagemaker.id

  tags = {
    Name = "sagemaker-igw"
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets (for NAT Gateway)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.sagemaker.id
  cidr_block              = cidrsubnet(aws_vpc.sagemaker.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "sagemaker-public-${count.index + 1}"
  }
}

# Private Subnets (for SageMaker Domain)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.sagemaker.id
  cidr_block        = cidrsubnet(aws_vpc.sagemaker.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "sagemaker-private-${count.index + 1}"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "sagemaker-nat-eip"
  }

  depends_on = [aws_internet_gateway.sagemaker]
}

# NAT Gateway
resource "aws_nat_gateway" "sagemaker" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "sagemaker-nat"
  }

  depends_on = [aws_internet_gateway.sagemaker]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sagemaker.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sagemaker.id
  }

  tags = {
    Name = "sagemaker-public-rt"
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.sagemaker.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.sagemaker.id
  }

  tags = {
    Name = "sagemaker-private-rt"
  }
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
