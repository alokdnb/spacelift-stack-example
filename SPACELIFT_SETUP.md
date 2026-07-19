# Spacelift Stack Setup Guide

This guide walks you through connecting the `spacelift-stack-example` repository to your Spacelift workspace at `alokdnb.app.us.spacelift.io`.

## Prerequisites

- Spacelift account with admin access
- GitHub repository: https://github.com/alokdnb/spacelift-stack-example
- AWS account credentials configured
- Spacelift API token (optional, but recommended)

## Option 1: Manual Setup via Spacelift UI (Recommended for First-Time Setup)

### Step 1: Connect GitHub Repository

1. Log in to your Spacelift workspace: https://alokdnb.app.us.spacelift.io
2. Navigate to **Integrations** → **Source Control** → **GitHub**
3. If not already connected, click **Connect** and authorize Spacelift to access your GitHub account
4. Select the organization `alokdnb`

### Step 2: Create a New Stack

1. Go to **Stacks** in the left navigation
2. Click **+ New Stack**
3. Fill in the following:

   | Field | Value |
   |-------|-------|
   | **Repository** | `alokdnb/spacelift-stack-example` |
   | **Branch** | `main` |
   | **Stack Name** | `spacelift-example-dev` |
   | **Project Root** | `.` (root of repo) |
   | **Description** | `Example Spacelift stack using terraform-module-example` |

4. Click **Create Stack**

### Step 3: Configure Stack Settings

After the stack is created:

1. Click on **spacelift-example-dev** to open the stack
2. Navigate to **Settings**
3. Configure the following:

   **Terraform Settings:**
   - Version: `1.5.0`
   - Workspace: `default`

   **Behavior:**
   - Auto Deploy: `Disabled` (change to Enabled after testing)
   - Auto Destroy: `Disabled`

   **Runner:**
   - Select appropriate runner pool (or use default)

4. Click **Save**

### Step 4: Set Environment Variables

Go to **Stack** → **Environment** and add:

```
TF_LOG=INFO
TF_INPUT=false
AWS_REGION=us-east-1
```

### Step 5: Set AWS Credentials

In **Stack** → **Secrets**, add your AWS credentials:

```
AWS_ACCESS_KEY_ID=<your-access-key>
AWS_SECRET_ACCESS_KEY=<your-secret-key>
```

Or if using IAM roles (recommended for production):
- Configure the runner to use IAM role with appropriate permissions

### Step 6: Configure Policies

1. Go to **Stack** → **Policies**
2. Enable the following policies:
   - `policies/access.rego` - Access Control
   - `policies/cost.rego` - Cost Optimization (optional)

### Step 7: Test the Stack

1. Go to the stack page
2. Click **New Run** (top right)
3. Select **Plan**
4. Review the plan output
5. If satisfied, click **Apply**

## Option 2: Using Spacelift CLI (spacectl)

### Step 1: Authenticate spacectl

```bash
spacectl profile login \
  --instance alokdnb \
  --instance-url alokdnb.app.us.spacelift.io \
  --token <your-spacelift-api-token>
```

**To generate an API token:**
1. Log in to Spacelift
2. Go to **Settings** → **API** → **API Keys**
3. Click **Create API Key**
4. Copy the key and use it above

### Step 2: Create Stack via CLI

```bash
spacectl stack create \
  --name spacelift-example-dev \
  --description "Example Spacelift stack using terraform-module-example" \
  --repository "alokdnb/spacelift-stack-example" \
  --branch main \
  --project-root "." \
  --terraform-version 1.5.0
```

### Step 3: Trigger Initial Plan

```bash
spacectl stack set-var \
  spacelift-example-dev \
  --name TF_LOG \
  --value INFO \
  --env

spacectl run create spacelift-example-dev --plan
```

## Option 3: Using GraphQL API

### Step 1: Get Your Spacelift API Token

1. Log in to Spacelift
2. Go to **Settings** → **API** → **API Keys**
3. Click **Create API Key** and copy the token

### Step 2: Create Stack via API

```bash
#!/bin/bash

API_TOKEN="<your-api-token>"
SPACELIFT_INSTANCE="alokdnb"
ENDPOINT="https://${SPACELIFT_INSTANCE}.app.us.spacelift.io/graphql"

# GraphQL mutation to create stack
MUTATION=$(cat <<'EOF'
mutation {
  stackCreate(
    input: {
      name: "spacelift-example-dev"
      description: "Example Spacelift stack using terraform-module-example"
      branch: "main"
      projectRoot: "."
      gitHub: {
        repository: "alokdnb/spacelift-stack-example"
      }
      terraform: {
        version: "1.5.0"
      }
    }
  ) {
    stack {
      id
      name
      slug
    }
  }
}
EOF
)

# Execute GraphQL mutation
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -d @- "${ENDPOINT}" << PAYLOAD
{
  "query": "$(echo "$MUTATION" | sed 's/"/\\"/g')"
}
PAYLOAD
```

## Post-Setup Configuration

### 1. Add Slack Notifications (Optional)

1. Go to **Stack** → **Notifications**
2. Click **+ Add Notification**
3. Select **Slack**
4. Provide webhook URL:
   - Get webhook from Slack workspace settings
   - Configure channels: `#spacelift-notifications`

### 2. Configure AWS Backend State Storage

The stack expects an S3 backend. Create or update:

```hcl
terraform {
  backend "s3" {
    bucket         = "spacelift-terraform-state"
    key            = "stacks/spacelift-example-dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "spacelift-terraform-locks"
  }
}
```

Or use Spacelift-managed state (recommended for simplicity).

### 3. Create S3 Backend Infrastructure

```bash
# Run this once to set up backend
aws s3 mb s3://spacelift-terraform-state --region us-east-1
aws s3api put-bucket-versioning \
  --bucket spacelift-terraform-state \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-server-side-encryption-configuration \
  --bucket spacelift-terraform-state \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for locks
aws dynamodb create-table \
  --table-name spacelift-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 4. Create SSH Key for Module Resolution (if using private modules)

If `terraform-module-example` becomes private:

1. Generate SSH key: `ssh-keygen -t ed25519 -f ~/.ssh/spacelift`
2. Add public key as deploy key to module repo on GitHub
3. In Spacelift: **Stack** → **Integrations** → **SSH Key** → Upload private key

### 5. Configure RBAC (Access Control)

1. Go to **Stack** → **Access Control**
2. Set role permissions:
   - **Admin**: Can plan, apply, and destroy
   - **Reviewer**: Can review and comment on runs
   - **Viewer**: Read-only access

## First Run Workflow

1. **Trigger Plan**
   ```bash
   spacectl run create spacelift-example-dev --plan
   ```

2. **Review Plan Output**
   - Check Spacelift UI for plan details
   - Review policy compliance
   - Check estimated costs

3. **Approve and Apply**
   ```bash
   spacectl run approve <run-id>
   spacectl run apply <run-id>
   ```

4. **Monitor Application**
   - Watch Spacelift UI for apply progress
   - Check AWS console for resources created
   - Verify S3 bucket was created

## Troubleshooting

### GitHub Repository Not Found

- Ensure `alokdnb/spacelift-stack-example` is public or Spacelift has access
- Check GitHub organization settings for SSH key authorization

### Terraform Module Not Found

```
Error: Failed to download module from github.com/alokdnb/terraform-module-example
```

**Solution:**
- Ensure `terraform-module-example` is public
- Or configure SSH key in Spacelift for private repo access

### State Lock Issues

```
Error: Error acquiring the state lock
```

**Solution:**
- Check if another run is in progress
- Force unlock (use with caution):
  ```bash
  spacectl state unlock spacelift-example-dev
  ```

### AWS Permission Errors

```
Error: error creating S3 Bucket
```

**Solution:**
- Verify AWS credentials in Spacelift secrets
- Check IAM policy has S3 permissions
- Ensure AWS account has no service control policies blocking S3

## Monitoring and Maintenance

### View Stack Status

```bash
spacectl stack describe spacelift-example-dev
```

### View Recent Runs

```bash
spacectl run list spacelift-example-dev --limit 10
```

### Update Stack Settings

```bash
spacectl stack set-env spacelift-example-dev \
  --name AWS_REGION \
  --value us-west-2
```

## Next Steps

1. Verify the stack works with a successful plan
2. Extend with additional environments (staging, prod)
3. Integrate with your CI/CD pipeline
4. Set up automated notifications
5. Create additional stacks for other infrastructure

## Support

- Spacelift Docs: https://docs.spacelift.io/
- Spacelift Community: https://spacelift.io/community
- Repository Issues: https://github.com/alokdnb/spacelift-stack-example/issues
