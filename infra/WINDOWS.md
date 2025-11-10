# Windows Setup Guide

Quick guide for deploying LibreChat on Azure from Windows.

## Prerequisites

Install these on Windows:

1. **Azure CLI** - https://aka.ms/installazurecliwindows
2. **Terraform** - https://www.terraform.io/downloads
3. **Docker Desktop** - https://www.docker.com/products/docker-desktop
4. **Git** (optional) - https://git-scm.com/download/win

## Quick Start

### 1. Open PowerShell or Command Prompt

```powershell
# Navigate to project
cd C:\path\to\LibreChat\infra
```

### 2. Login to Azure

```powershell
az login
az account list --output table
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 3. Configure Terraform

```powershell
# Copy example config
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit with your subscription ID
notepad terraform.tfvars
```

### 4. Deploy Infrastructure

```powershell
terraform init
terraform apply
```

Type `yes` when prompted. Wait ~15 minutes.

### 5. Configure .env File

```powershell
# Go to project root
cd ..

# Edit .env
notepad .env
```

Get values from Terraform:
```powershell
cd infra
terraform output -raw cosmos_db_connection_string  # Copy to MONGO_URI
terraform output -raw meili_master_key             # Copy to MEILI_MASTER_KEY
terraform output -raw jwt_secret                   # Copy to JWT_SECRET
terraform output -raw jwt_refresh_secret           # Copy to JWT_REFRESH_SECRET
```

Fill in:
- `MONGO_URI` - Cosmos DB connection string (from Terraform)
- `MEILI_MASTER_KEY` - MeiliSearch key (from Terraform)
- `JWT_SECRET` - JWT secret (from Terraform)
- `JWT_REFRESH_SECRET` - JWT refresh secret (from Terraform)
- `OPENAI_API_KEY` - Your OpenAI key
- Other API keys as needed

### 6. Build and Deploy

**Option A: PowerShell**
```powershell
cd infra
.\build.ps1
terraform apply
```

**Option B: Command Prompt**
```cmd
cd infra
build.cmd
terraform apply
```

### 7. Access Your App

```powershell
# Get URL
terraform output librechat_url

# Or open in browser
start (terraform output -raw librechat_url)
```

## Building with Custom Version Tag

**PowerShell:**
```powershell
.\build.ps1 -ImageTag "v1.0.0"
```

**Command Prompt:**
```cmd
set IMAGE_TAG=v1.0.0
build.cmd
```

## Common Issues

### "Execution policy" error

If you see this error when running `.\build.ps1`:
```
File cannot be loaded because running scripts is disabled
```

**Solution:**
Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Or use `build.cmd` instead (bypasses policy).

### Docker not found

Make sure Docker Desktop is installed and running.

Check:
```powershell
docker --version
```

### Terraform not found

Add Terraform to your PATH or use full path:
```powershell
C:\path\to\terraform.exe init
```

### Azure CLI not found

Install from: https://aka.ms/installazurecliwindows

Or use MSI installer:
```powershell
# Check if installed
az --version
```

## Line Endings

If you cloned the repo on Windows, Git may have converted line endings. This can cause issues with shell scripts.

**Fix:**
```powershell
# In infra directory
git config core.autocrlf false
git rm --cached -r .
git reset --hard
```

## Editing .env

Use any text editor:
```powershell
notepad .env              # Notepad
code .env                 # VS Code
notepad++ .env            # Notepad++
```

Make sure to save with UTF-8 encoding (no BOM).

## Troubleshooting

### View .env contents
```powershell
Get-Content .env | Select -First 10
```

### View Terraform outputs
```powershell
cd infra
terraform output
```

### View container logs
Install Azure CLI, then:
```powershell
$RG = terraform output -raw resource_group_name
$APP = az containerapp list -g $RG --query "[?contains(name, 'librechat-app')].name" -o tsv
az containerapp logs show --name $APP --resource-group $RG --follow
```

## Quick Commands Reference

```powershell
# Build
.\build.ps1

# Build with tag
.\build.ps1 -ImageTag "v1.0.1"

# Deploy
terraform apply

# Outputs
terraform output
terraform output librechat_url

# Destroy
terraform destroy
```

## Path Differences

Windows uses backslashes for paths:

```powershell
# Correct for Windows
cd C:\Users\YourName\LibreChat\infra
Copy-Item .env.azure.example ..\.env

# Not forward slashes
cd C:/Users/YourName/LibreChat/infra  # This works in PowerShell but not CMD
```

## Environment Variables (PowerShell)

Set environment variables:
```powershell
$env:IMAGE_TAG = "v1.0.0"
.\build.ps1
```

## Environment Variables (Command Prompt)

Set environment variables:
```cmd
set IMAGE_TAG=v1.0.0
build.cmd
```

## Next Steps

See main [README.md](README.md) for detailed documentation.
