# Quick Setup Guide

## 🚀 Three Ways to Deploy

### Method 1: Spacelift UI (Easiest for First-Time)

```
1. Open: https://alokdnb.app.us.spacelift.io
2. Click: Stacks → + New Stack
3. Select: Repository "alokdnb/spacelift-stack-example"
4. Branch: main
5. Name: spacelift-example-dev
6. Create
7. Configure AWS credentials in Settings
8. Create Run → Plan
```

### Method 2: Using spacectl CLI

```bash
# Login
spacectl profile login \
  --instance alokdnb \
  --instance-url alokdnb.app.us.spacelift.io

# Create stack
spacectl stack create \
  --name spacelift-example-dev \
  --repository "alokdnb/spacelift-stack-example" \
  --branch main

# Trigger plan
spacectl run create spacelift-example-dev --plan
```

### Method 3: Using GraphQL API

```bash
# Get your API token from Settings → API → API Keys
./scripts/create-stack-api.sh <your-api-token>
```

## ✅ Post-Creation Checklist

- [ ] Stack created in Spacelift UI
- [ ] GitHub repository connected
- [ ] AWS credentials configured (Settings → Secrets)
- [ ] Environment variables set (TF_LOG, AWS_REGION)
- [ ] Terraform version set to 1.5.0
- [ ] Initial plan runs successfully
- [ ] S3 bucket created after apply

## 🔍 Verify Success

```bash
# Check stack status
spacectl stack describe spacelift-example-dev

# List recent runs
spacectl run list spacelift-example-dev

# View created resources in AWS
aws s3 ls | grep spacelift-example
```

## 📚 Full Documentation

See `SPACELIFT_SETUP.md` for comprehensive setup guide with troubleshooting.
