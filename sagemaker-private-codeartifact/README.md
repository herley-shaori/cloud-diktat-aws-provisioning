# SageMaker Private Subnet with CodeArtifact Integration

Deploy a SageMaker Notebook Instance in a fully isolated private subnet while still being able to install Python packages via AWS CodeArtifact.

## Architecture Overview

```
                                    ┌──────────────────┐
                                    │   Public PyPI    │
                                    │  (pypi.org)      │
                                    └────────▲─────────┘
                                             │
                                             │ External Connection
                                             │ (CodeArtifact fetches)
┌────────────────────────────────────────────┼────────────────────────────────┐
│                                  AWS Cloud │                                │
│  ┌─────────────────────────────────────────┼─────────────────────────────┐  │
│  │                        VPC (10.0.0.0/16)│                             │  │
│  │                                         │                             │  │
│  │  ┌─────────────────┐              ┌─────┴──────────┐                  │  │
│  │  │ Private Subnet  │              │  CodeArtifact  │                  │  │
│  │  │  (10.0.1.0/24)  │              │                │                  │  │
│  │  │                 │              │  ┌──────────┐  │                  │  │
│  │  │  ┌───────────┐  │  VPC         │  │pypi-store│◄─┼── public:pypi   │  │
│  │  │  │ SageMaker │  │  Endpoint    │  └────┬─────┘  │                  │  │
│  │  │  │ Notebook  │──┼──────────────┼───►   │        │                  │  │
│  │  │  │           │  │  (Private)   │  ┌────▼─────┐  │                  │  │
│  │  │  │ pip install│ │              │  │sagemaker-│  │                  │  │
│  │  │  └───────────┘  │              │  │packages  │  │                  │  │
│  │  │                 │              │  └──────────┘  │                  │  │
│  │  │  ❌ No Internet │              └────────────────┘                  │  │
│  │  └─────────────────┘                                                  │  │
│  │                                                                       │  │
│  │  VPC Endpoints:                                                       │  │
│  │  • codeartifact.api        • sagemaker.api      • ecr.api            │  │
│  │  • codeartifact.repositories • sagemaker.runtime • ecr.dkr           │  │
│  │  • sts                     • notebook           • logs               │  │
│  │  • s3 (Gateway)                                                      │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## How It Works

1. **SageMaker Notebook** runs in a private subnet with `direct_internet_access = "Disabled"`
2. **VPC Endpoints** provide private connectivity to AWS services (no internet required)
3. **CodeArtifact** acts as a proxy/cache for Python packages:
   - `pypi-store` repository has an external connection to `public:pypi`
   - `sagemaker-packages` repository uses `pypi-store` as upstream
   - CodeArtifact fetches packages from PyPI and caches them
4. **Lifecycle Configuration** automatically configures pip to use CodeArtifact on notebook start

## Key Benefits

| Benefit | Description |
|---------|-------------|
| **Security** | SageMaker has no internet access, reducing attack surface |
| **Compliance** | Data never leaves the private network |
| **Package Caching** | Packages are cached in CodeArtifact, faster subsequent installs |
| **Auditability** | All package downloads are logged in CodeArtifact |
| **Cost Efficient** | No NAT Gateway costs for package downloads |

## Project Structure

```
sagemaker-private-codeartifact/
├── versions.tf          # Terraform & AWS provider configuration
├── variables.tf         # Input variables with defaults
├── locals.tf            # Computed values and endpoint definitions
├── vpc.tf               # VPC, subnets, route tables, security groups
├── vpc-endpoints.tf     # Interface and gateway VPC endpoints
├── codeartifact.tf      # CodeArtifact domain and repositories
├── iam.tf               # IAM roles and policies for SageMaker
├── sagemaker.tf         # Notebook instance and lifecycle configuration
├── outputs.tf           # Output values
└── README.md            # This file
```

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- Sufficient IAM permissions to create VPC, SageMaker, CodeArtifact resources

## Usage

### 1. Initialize Terraform

```bash
cd sagemaker-private-codeartifact
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

### 4. Access the Notebook

After deployment, access your notebook via the AWS Console URL provided in the outputs.

## Configuration

### Default Values

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `ap-southeast-3` | AWS Jakarta region |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `sagemaker_instance_type` | `ml.t3.medium` | Notebook instance type |
| `codeartifact_domain_name` | `mlplatform` | CodeArtifact domain |
| `environment` | `dev` | Environment tag |

### Customization

Create a `terraform.tfvars` file to override defaults:

```hcl
aws_region              = "ap-southeast-3"
environment             = "prod"
project_name            = "ml-platform"
sagemaker_instance_type = "ml.t3.large"
sagemaker_volume_size   = 100
```

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the created VPC |
| `private_subnet_ids` | IDs of private subnets |
| `sagemaker_notebook_url` | Console URL for the notebook |
| `codeartifact_repository_endpoint` | CodeArtifact PyPI endpoint |
| `codeartifact_pip_login_command` | CLI command to configure pip locally |

## Using pip in the Notebook

The lifecycle configuration automatically configures pip. Simply use pip as normal:

```bash
# In a notebook cell or terminal
!pip install pandas numpy scikit-learn
```

### Refreshing the Token

CodeArtifact tokens expire after 12 hours. If needed, refresh manually:

```bash
# Run in notebook terminal
~/refresh-codeartifact-token.sh
```

## Local Development

To configure your local machine to use the same CodeArtifact repository:

```bash
# Get the login command from Terraform output
terraform output -raw codeartifact_pip_login_command | bash
```

## Cost Considerations

| Resource | Cost |
|----------|------|
| VPC Endpoints (Interface) | ~$0.01/hour each + data processing |
| VPC Endpoint (S3 Gateway) | Free |
| SageMaker ml.t3.medium | ~$0.05/hour (when running) |
| CodeArtifact | $0.05/GB stored + $0.09/GB transferred |

**Tip**: Stop the notebook instance when not in use to reduce costs.

## Security Considerations

- SageMaker notebook has no direct internet access
- All traffic to AWS services goes through VPC endpoints
- IAM policies follow least-privilege principle
- Security groups restrict traffic to necessary ports only
- CodeArtifact provides audit trail for all package downloads

## Troubleshooting

### pip install fails with connection error

1. Verify VPC endpoints are created and healthy
2. Check security group allows HTTPS (443) from VPC CIDR
3. Verify IAM role has CodeArtifact permissions

### Packages not found

1. Ensure the package exists on PyPI
2. Check CodeArtifact external connection is active
3. Try: `aws codeartifact list-packages --domain mlplatform --repository sagemaker-packages`

### Token expired

```bash
# Refresh the token
~/refresh-codeartifact-token.sh
```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

**Note**: Ensure the SageMaker notebook is stopped before destroying.

## License

MIT License
