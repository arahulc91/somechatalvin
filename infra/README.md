# LibreChat Azure Deployment

Deploy LibreChat to Azure with Cosmos DB (MongoDB API).

## Architecture

- **Azure Cosmos DB** - MongoDB API for database
- **Azure Container Apps** - LibreChat, MeiliSearch, PostgreSQL (pgvector), RAG API
- **Azure Container Registry** - Private Docker registry
- **Azure Storage** - File storage (uploads, images)
- **Azure Virtual Network** - Private networking

## Prerequisites

- Azure account with active subscription
- Azure CLI installed and logged in
- Terraform installed
- Docker installed

**Windows users:** See [WINDOWS.md](WINDOWS.md) for detailed Windows setup guide.

## Quick Start

### 1. Deploy Infrastructure

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars and set your subscription_id
vim terraform.tfvars

terraform init
terraform apply
```

Wait ~15 minutes for deployment to complete.

### 2. Configure .env File

```bash
# Edit .env in project root
cd ..
vim .env
```

Fill in these values from Terraform outputs:

```bash
cd infra

# Get Cosmos DB connection string
terraform output -raw cosmos_db_connection_string
# → Copy to MONGO_URI in .env

# Get MeiliSearch key
terraform output -raw meili_master_key
# → Copy to MEILI_MASTER_KEY in .env

# Get JWT secrets
terraform output -raw jwt_secret
# → Copy to JWT_SECRET in .env

terraform output -raw jwt_refresh_secret
# → Copy to JWT_REFRESH_SECRET in .env
```

Also add your API keys:
- `OPENAI_API_KEY` - Your OpenAI API key
- `ANTHROPIC_API_KEY` - Your Anthropic API key (optional)
- `GOOGLE_KEY` - Your Google API key (optional)

### 3. Build and Deploy

```bash
cd infra

# Build Docker image with .env
./build.sh              # Linux/Mac
# or
.\build.ps1             # Windows (PowerShell)
# or
build.cmd               # Windows (Command Prompt)

# Deploy
terraform apply
```

### 4. Access Your App

```bash
# Get URL
terraform output librechat_url

# Or open directly
make open
```

## Configuration

### .env File

All configuration goes in `.env` file (baked into Docker image):
- AI provider API keys
- Database connection
- Security settings
- Feature flags

Edit the `.env` file in project root and fill in values from Terraform outputs.

### librechat.yaml

Application configuration (also baked into image):
- AI endpoints and models
- Interface customization
- Feature settings

Located at project root. Edit and rebuild to apply changes.

## Updating

Any change to `.env` or `librechat.yaml` requires rebuilding:

**Linux/Mac:**
```bash
# 1. Edit configuration
vim .env
# or
vim librechat.yaml

# 2. Rebuild (with new version tag)
cd infra
IMAGE_TAG=v1.0.1 ./build.sh

# 3. Update terraform.tfvars
echo 'image_tag = "v1.0.1"' >> terraform.tfvars

# 4. Deploy
terraform apply
```

**Windows:**
```powershell
# 1. Edit configuration
notepad .env
# or
notepad librechat.yaml

# 2. Rebuild (with new version tag)
cd infra
.\build.ps1 -ImageTag "v1.0.1"

# 3. Update terraform.tfvars
Add-Content terraform.tfvars "image_tag = `"v1.0.1`""

# 4. Deploy
terraform apply
```

## Commands

**Linux/Mac (Makefile):**
```bash
make help       # Show all commands
make build      # Build and push image
make apply      # Deploy changes
make logs       # View logs
make status     # Check status
make restart    # Restart app
make open       # Open in browser
```

**Windows:**
```powershell
.\build.ps1              # Build and push image
terraform apply          # Deploy changes
# For logs, see WINDOWS.md
```

## Infrastructure Changes

To change CPU, memory, or other infrastructure:

```bash
# Edit terraform.tfvars
vim terraform.tfvars

# Apply (no rebuild needed)
terraform apply
```

## Cleanup

```bash
terraform destroy
```

## Costs

Estimated monthly cost: ~$50-130

- Cosmos DB (Serverless): ~$10-50
- Container Apps: ~$30-60
- Storage: ~$5-10
- Log Analytics: ~$5-10

## Troubleshooting

### .env not found

```bash
# Check .env exists in project root
ls -la .env

# Should be in same directory as package.json
ls .env package.json
```

### App won't start

```bash
make logs  # Check what's wrong
```

### Database connection errors

```bash
# Verify MONGO_URI in .env matches Terraform output
cd infra
terraform output cosmos_db_connection_string
```

## Files

```
infra/
├── *.tf                     # Terraform infrastructure
├── build.sh                 # Build script (Linux/Mac)
├── build.ps1                # Build script (Windows)
├── build.cmd                # Build script (Windows CMD)
├── Dockerfile.custom        # Dockerfile that includes .env
├── .dockerignore.custom     # Allows .env in build
└── Makefile                 # Quick commands (Linux/Mac)
```

## Notes

- `.env` and `librechat.yaml` are baked into the Docker image
- Changes to either require rebuilding the image
- Keep your ACR private (contains your secrets)
- Use version tags for production (`v1.0.0`, `v1.0.1`, etc.)
