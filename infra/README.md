# LibreChat Azure Deployment - Windows

Deploy LibreChat to Azure using Terraform from Windows.

## Prerequisites

Install on Windows:
1. **Azure CLI** - https://aka.ms/installazurecliwindows
2. **Terraform** - https://www.terraform.io/downloads
3. **Docker Desktop** - https://www.docker.com/products/docker-desktop

## Deployment Steps

### 1. Login to Azure

```powershell
az login
az account list --output table
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Configure Terraform

```powershell
cd infra
notepad terraform.tfvars
```

Edit `terraform.tfvars` and set your `subscription_id`.

### 3. Deploy Infrastructure

```powershell
terraform init
terraform apply
```

Type `yes` when prompted. Wait ~15 minutes.

### 4. Build Docker Image

Get your ACR login server:
```powershell
$ACR_NAME = terraform output -raw acr_name
$ACR_SERVER = terraform output -raw acr_login_server
```

Login to ACR:
```powershell
az acr login --name $ACR_NAME
```

Build and push image:
```powershell
cd ..
docker build -f infra/Dockerfile.custom -t "${ACR_SERVER}/librechat:latest" .
docker push "${ACR_SERVER}/librechat:latest"
```

### 5. Deploy Application

```powershell
cd infra
terraform apply
```

### 6. Access Your App

```powershell
terraform output librechat_url
```

Open the URL in your browser.

## Updating

After changing `.env` or `librechat.yaml`:

```powershell
# Build with new version tag
cd ..
$ACR_SERVER = terraform output -raw acr_login_server
docker build -f infra/Dockerfile.custom -t "${ACR_SERVER}/librechat:v1.0.1" .
docker push "${ACR_SERVER}/librechat:v1.0.1"

# Update terraform.tfvars
cd infra
notepad terraform.tfvars  # Set: image_tag = "v1.0.1"

# Deploy
terraform apply
```

## Get Configuration Values

```powershell
terraform output -raw cosmos_db_connection_string
terraform output -raw meili_master_key
terraform output -raw jwt_secret
terraform output -raw jwt_refresh_secret
```

## Cleanup

```powershell
terraform destroy
```
