# =============================================================================
# VPC and Network Infrastructure
# =============================================================================
# Creates a fully isolated VPC with private subnets for SageMaker.
# No NAT Gateway is used - all external access is through VPC Endpoints.
# =============================================================================

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # Required for VPC endpoints
  enable_dns_support   = true # Required for VPC endpoints

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------
# These subnets have no route to the internet. All external communication
# happens through VPC Endpoints.

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
    Type = "private"
  }
}

# -----------------------------------------------------------------------------
# Route Table for Private Subnets
# -----------------------------------------------------------------------------
# Contains only local VPC routes and S3 gateway endpoint route.

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# -----------------------------------------------------------------------------
# Security Group for VPC Endpoints
# -----------------------------------------------------------------------------
# Allows HTTPS traffic from within the VPC for endpoint communication.

resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name_prefix}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints - allows HTTPS from VPC"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-vpc-endpoints-sg"
  }
}

# -----------------------------------------------------------------------------
# Security Group for SageMaker Notebook
# -----------------------------------------------------------------------------
# Controls network access to/from the SageMaker notebook instance.

resource "aws_security_group" "sagemaker" {
  name        = "${local.name_prefix}-sagemaker-sg"
  description = "Security group for SageMaker notebook instance"
  vpc_id      = aws_vpc.main.id

  # Allow HTTPS outbound for VPC endpoints
  egress {
    description     = "HTTPS to VPC endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.vpc_endpoints.id]
  }

  # Allow HTTPS outbound to VPC CIDR (for S3 gateway endpoint)
  egress {
    description = "HTTPS to VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all traffic within the security group (for distributed training)
  ingress {
    description = "All traffic from same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "All traffic to same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  tags = {
    Name = "${local.name_prefix}-sagemaker-sg"
  }
}
