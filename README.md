# Azure Workload Identity Federation (GitHub → Azure)

Secure authentication from GitHub Actions to Azure **without storing any secrets**.

## What it does
- Creates a User Assigned Managed Identity
- Sets up OIDC federation with GitHub
- Assigns permissions (Contributor)

## How to Deploy
```bash
terraform init
terraform plan
terraform apply
