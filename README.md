# Spacelift Stack: Example Development Environment

A complete Spacelift stack configuration that demonstrates best practices for infrastructure-as-code management using Terraform and the `terraform-module-example` module.

## Overview

This repository contains a Spacelift stack that:
- Uses the modular `terraform-module-example` for AWS S3 bucket creation
- Implements policy-as-code (Rego) for access control and cost management
- Includes comprehensive state management and locking
- Demonstrates Spacelift hooks and notifications
- Provides examples of environment-based configuration

## Prerequisites

- Spacelift account and workspace
- AWS account with appropriate permissions
- Terraform >= 1.0
- Git repository connected to Spacelift

## Repository Structure

```
.
├── main.tf                          # Main stack configuration using the module
├── variables.tf                     # Input variables and defaults
├── outputs.tf                       # Stack outputs
├── spacelift.yml                    # Spacelift stack configuration
├── terraform.tfvars.example         # Example variable values
├── .gitignore                       # Git ignore rules
├── policies/
│   ├── access.rego                 # Access control policies
│   └── cost.rego                   # Cost optimization policies (optional)
└── README.md                        # This file
```

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/alokdnb/spacelift-stack-example.git
cd spacelift-stack-example
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Connect to Spacelift

1. Log in to your Spacelift workspace
2. Create a new stack pointing to this repository
3. Configure the stack settings based on `spacelift.yml`
4. Set the tracked branch to `main`

### 4. Plan and Apply

Use Spacelift UI or CLI to:
1. **Plan** - Review the Terraform plan
2. **Review** - Check policy violations (if any)
3. **Apply** - Deploy the infrastructure

## Configuration Details

### Terraform Module

This stack uses `terraform-module-example` which creates:
- **S3 Bucket** with configurable name
- **Versioning** (optional, enabled by default)
- **Encryption** (AES256 by default)
- **Public Access Blocking** (enabled by default)

### Spacelift Stack Configuration (`spacelift.yml`)

Key sections:

- **Backend**: S3 state storage with DynamoDB locking
- **Terraform**: Version constraints and workflow hooks
- **Policies**: Rego policies for governance
- **Hooks**: Notifications and webhook integrations
- **Labels**: Organization and filtering
- **Access Control**: Role-based access control (RBAC)

### Policies

#### Access Control Policy (`policies/access.rego`)
- Admin bypass for all actions
- Stack admin permissions for plan/apply
- Production protection (no destroy)
- Approval requirements for production changes

#### Cost Optimization Policy (`policies/cost.rego`) - Optional
- Resource tagging enforcement
- Instance type recommendations
- Encryption enforcement
- S3 lifecycle rule suggestions

## Variables

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `aws_region` | string | `us-east-1` | No | AWS region for resources |
| `bucket_name` | string | `spacelift-example-dev-bucket` | No | S3 bucket name |
| `enable_versioning` | bool | `true` | No | Enable S3 versioning |
| `block_public_access` | bool | `true` | No | Block public S3 access |
| `common_tags` | map(string) | See defaults | No | Common resource tags |
| `spacelift_environment` | string | `dev` | No | Environment identifier |

## Outputs

- `bucket_id` - The ID of the created S3 bucket
- `bucket_arn` - The ARN of the S3 bucket
- `bucket_region` - The AWS region
- `bucket_domain_name` - The regional domain name
- `module_version` - Reference to the module used

## Deployment Workflow

### Development Environment

```hcl
# terraform.tfvars
aws_region = "us-east-1"
bucket_name = "spacelift-example-dev-bucket"
enable_versioning = true
block_public_access = true
spacelift_environment = "dev"
```

### Production Environment

For production deployments:

1. Create a separate Spacelift stack pointing to a `production` branch
2. Update `spacelift.yml` with production policies
3. Configure additional hooks and approvals
4. Set `auto_deploy = false` and require manual approvals

## Security Best Practices

✓ **State Management**: Encrypted S3 backend with DynamoDB locks
✓ **Access Control**: Rego policies enforce RBAC
✓ **Secrets**: Use Spacelift secrets management (not in code)
✓ **Encryption**: S3 bucket encryption enabled by default
✓ **Auditing**: All changes tracked via Spacelift audit logs
✓ **Approval Workflow**: Production changes require approval

## Hooks and Notifications

The stack is configured with:

- **Before Init**: Webhook notification
- **Before Plan**: Slack notification to #spacelift-notifications
- **After Plan**: Slack notification with plan summary
- **Before Apply**: Webhook validation
- **After Apply**: Slack confirmation

## Troubleshooting

### Terraform Validation Fails

```bash
terraform init
terraform validate
```

### State Lock Issues

Check if another operation is in progress:
```bash
# In AWS
aws dynamodb scan --table-name spacelift-terraform-locks
```

### Module Resolution

Ensure the `terraform-module-example` repository is public or configure authentication:
```hcl
# In spacelift.yml
git_auth:
  - type: ssh_key
    repo_slug: alokdnb/terraform-module-example
```

## Contributing

1. Create a feature branch
2. Make changes and test locally
3. Push to GitHub
4. Create a pull request
5. Spacelift will automatically plan changes
6. After review and approval, merge to main

## Related Repositories

- [terraform-module-example](https://github.com/alokdnb/terraform-module-example) - The Terraform module used by this stack
- [Spacelift Documentation](https://docs.spacelift.io/)

## License

Apache 2.0
