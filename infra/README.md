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

### 4. Configure .env File

Go to project root and edit `.env`:

```powershell
cd ..
notepad .env
```

Get values from Terraform and add to `.env`:

```powershell
cd infra

# Get Cosmos DB connection string
terraform output -raw cosmos_db_connection_string
# Copy this to MONGO_URI in .env

# Get MeiliSearch master key
terraform output -raw meili_master_key
# Copy this to MEILI_MASTER_KEY in .env

# Get JWT secrets
terraform output -raw jwt_secret
# Copy this to JWT_SECRET in .env

terraform output -raw jwt_refresh_secret
# Copy this to JWT_REFRESH_SECRET in .env

# Get Azure Storage credentials (for file uploads)
terraform output -raw storage_account_name
# Copy this to AZURE_STORAGE_ACCOUNT_NAME in .env

terraform output -raw storage_account_key
# Copy this to AZURE_STORAGE_ACCOUNT_KEY in .env

# Get PostgreSQL password (for RAG API)
terraform output -raw postgres_password
# Copy this to DB_PASSWORD in .env
```

Also add your API keys to `.env`:
- `OPENAI_API_KEY` - Your OpenAI API key
- `ANTHROPIC_API_KEY` - Your Anthropic API key (optional)
- `GOOGLE_KEY` - Your Google API key (optional)
- `AZURE_OPENAI_API_KEY` - Your Azure OpenAI key (optional)

### 5. Build Docker Image

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

### 6. Deploy Application

```powershell
cd infra
terraform apply
```

### 7. Access Your App

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
