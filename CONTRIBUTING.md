# Contributing Guide

## Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

Update Terraform files, policies, or configuration as needed.

### 3. Test Locally

```bash
terraform init
terraform validate
terraform plan
```

### 4. Commit and Push

```bash
git add .
git commit -m "feat: describe your changes"
git push origin feature/your-feature-name
```

### 5. Create a Pull Request

- Spacelift will automatically create a plan comment on your PR
- Review the plan and policy compliance
- Request approval from team members
- Once approved, merge to main

### 6. Monitor the Deployment

Spacelift will automatically apply changes after merging to main.

## Code Style

### Terraform

- Use 2-space indentation
- Format with `terraform fmt`
- Provide descriptive variable and output names
- Include comments for complex logic

### Rego Policies

- Follow OPA best practices
- Use clear rule names
- Include deny and warn rules
- Document policy intent in comments

## Pull Request Checklist

Before submitting a PR:

- [ ] Terraform files pass validation: `terraform validate`
- [ ] Code is formatted: `terraform fmt -recursive`
- [ ] Variables and outputs are documented
- [ ] Changes work in local environment
- [ ] No sensitive data (secrets, credentials) in code
- [ ] Updated README if adding new variables or outputs

## Spacelift Stack Rules

- Always set `auto_deploy = false` for manual control
- Production changes require approval
- Policies are enforced during planning
- All access is audited

## Troubleshooting

### Formatting Issues

```bash
terraform fmt -recursive .
```

### Module Dependency Issues

Ensure module version is accessible:
```bash
terraform init -upgrade
```

### State Conflicts

Check Spacelift UI for locking details. Contact platform team if stuck.

## Questions?

Reach out to the platform team in #spacelift-notifications Slack channel.
