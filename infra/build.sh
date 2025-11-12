#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  LibreChat Build & Push to ACR          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check if .env exists
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    echo -e "${RED}ERROR: .env file not found in project root!${NC}"
    exit 1
fi

# Check if terraform outputs exist
if [ ! -d "$SCRIPT_DIR/.terraform" ]; then
    echo -e "${RED}ERROR: Terraform not initialized. Run 'terraform init' first.${NC}"
    exit 1
fi

# Get ACR details from Terraform
echo -e "${YELLOW}→ Getting ACR credentials...${NC}"
cd "$SCRIPT_DIR"

ACR_LOGIN_SERVER=$(terraform output -raw container_registry_login_server 2>/dev/null)
ACR_USERNAME=$(terraform output -raw container_registry_admin_username 2>/dev/null)
ACR_PASSWORD=$(terraform output -raw container_registry_admin_password 2>/dev/null)

if [ -z "$ACR_LOGIN_SERVER" ]; then
    echo -e "${RED}ERROR: Could not get ACR details. Run 'terraform apply' first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ ACR: $ACR_LOGIN_SERVER${NC}"

# Setup custom build files
cp "$SCRIPT_DIR/.dockerignore.custom" "$PROJECT_ROOT/.dockerignore.tmp"
cp "$SCRIPT_DIR/Dockerfile.custom" "$PROJECT_ROOT/Dockerfile.tmp"

# Login to ACR
echo ""
echo -e "${YELLOW}→ Logging in to ACR...${NC}"
echo "$ACR_PASSWORD" | docker login "$ACR_LOGIN_SERVER" -u "$ACR_USERNAME" --password-stdin

if [ $? -ne 0 ]; then
    rm -f "$PROJECT_ROOT/.dockerignore.tmp" "$PROJECT_ROOT/Dockerfile.tmp"
    echo -e "${RED}ERROR: Failed to login to ACR${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Logged in${NC}"

# Build the image
echo ""
echo -e "${YELLOW}→ Building image: $ACR_LOGIN_SERVER/librechat:$IMAGE_TAG${NC}"
cd "$PROJECT_ROOT"

docker build \
    -f Dockerfile.tmp \
    -t "$ACR_LOGIN_SERVER/librechat:$IMAGE_TAG" \
    -t "$ACR_LOGIN_SERVER/librechat:$(git rev-parse --short HEAD 2>/dev/null || echo 'latest')" \
    .

BUILD_RESULT=$?
rm -f "$PROJECT_ROOT/.dockerignore.tmp" "$PROJECT_ROOT/Dockerfile.tmp"

if [ $BUILD_RESULT -ne 0 ]; then
    echo -e "${RED}ERROR: Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build complete${NC}"

# Push the image
echo ""
echo -e "${YELLOW}→ Pushing to ACR...${NC}"
docker push "$ACR_LOGIN_SERVER/librechat:$IMAGE_TAG"

if git rev-parse --short HEAD >/dev/null 2>&1; then
    COMMIT_HASH=$(git rev-parse --short HEAD)
    docker push "$ACR_LOGIN_SERVER/librechat:$COMMIT_HASH"
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Push failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Build Complete! ✨                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "Image: ${GREEN}$ACR_LOGIN_SERVER/librechat:$IMAGE_TAG${NC}"
echo ""
echo -e "${YELLOW}Next: terraform apply${NC}"
echo ""
