# VPC Endpoints for SageMaker Private Mode

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.sagemaker.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "sagemaker-s3-endpoint"
  }
}

# SageMaker API Interface Endpoint
resource "aws_vpc_endpoint" "sagemaker_api" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "com.amazonaws.${var.aws_region}.sagemaker.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-api-endpoint"
  }
}

# SageMaker Runtime Interface Endpoint
resource "aws_vpc_endpoint" "sagemaker_runtime" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "com.amazonaws.${var.aws_region}.sagemaker.runtime"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-runtime-endpoint"
  }
}

# SageMaker Studio Interface Endpoint
resource "aws_vpc_endpoint" "sagemaker_studio" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "aws.sagemaker.${var.aws_region}.studio"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-studio-endpoint"
  }
}

# STS Interface Endpoint
resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-sts-endpoint"
  }
}

# CloudWatch Logs Interface Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-logs-endpoint"
  }
}

# Service Catalog Interface Endpoint (for SageMaker Projects)
resource "aws_vpc_endpoint" "servicecatalog" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "com.amazonaws.${var.aws_region}.servicecatalog"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-servicecatalog-endpoint"
  }
}

# ECR API Interface Endpoint (for container images)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-ecr-api-endpoint"
  }
}

# ECR DKR Interface Endpoint (for Docker layer download)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.sagemaker.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "sagemaker-ecr-dkr-endpoint"
  }
}
