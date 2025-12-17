# Security Group for SageMaker Domain
resource "aws_security_group" "sagemaker" {
  name        = "sagemaker-domain-sg"
  description = "Security group for SageMaker Domain"
  vpc_id      = aws_vpc.sagemaker.id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # Allow inbound traffic from within the security group (for SageMaker apps)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow all traffic within security group"
  }

  tags = {
    Name = "sagemaker-domain-sg"
  }
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = aws_vpc.sagemaker.id

  # Allow HTTPS from SageMaker security group
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sagemaker.id]
    description     = "Allow HTTPS from SageMaker"
  }

  # Allow HTTPS from private subnets
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for s in aws_subnet.private : s.cidr_block]
    description = "Allow HTTPS from private subnets"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}
