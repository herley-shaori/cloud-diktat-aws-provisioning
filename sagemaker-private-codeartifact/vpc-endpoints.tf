# =============================================================================
# VPC Endpoints
# =============================================================================
# VPC Endpoints enable private connectivity to AWS services without requiring
# internet access. This is essential for a fully isolated private subnet.
# =============================================================================

# -----------------------------------------------------------------------------
# Interface Endpoints
# -----------------------------------------------------------------------------
# Interface endpoints create ENIs in the specified subnets for private
# connectivity to AWS services.

resource "aws_vpc_endpoint" "interface" {
  for_each = local.vpc_endpoint_services

  vpc_id              = aws_vpc.main.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.name_prefix}-${each.key}-endpoint"
  }
}

# -----------------------------------------------------------------------------
# Gateway Endpoint for S3
# -----------------------------------------------------------------------------
# S3 Gateway endpoint provides free, high-performance access to S3.
# It adds routes directly to the route table instead of creating ENIs.

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = local.gateway_endpoints.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${local.name_prefix}-s3-endpoint"
  }
}

# -----------------------------------------------------------------------------
# VPC Endpoint Policy for S3 (Optional - restricts S3 access)
# -----------------------------------------------------------------------------
# This policy can be customized to restrict which S3 buckets can be accessed
# through the endpoint. Currently allows all S3 access.

resource "aws_vpc_endpoint_policy" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAll"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "*"
      }
    ]
  })
}
