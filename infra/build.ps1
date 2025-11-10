# PowerShell build script for Windows
[CmdletBinding()]
param(
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Success "╔══════════════════════════════════════════╗"
Write-Success "║  LibreChat Build & Push to ACR          ║"
Write-Success "╚══════════════════════════════════════════╝"
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

# Check if .env exists
$EnvFile = Join-Path $ProjectRoot ".env"
if (-not (Test-Path $EnvFile)) {
    Write-Error "ERROR: .env file not found in project root!"
    exit 1
}

# Check if terraform is initialized
$TerraformDir = Join-Path $ScriptDir ".terraform"
if (-not (Test-Path $TerraformDir)) {
    Write-Error "ERROR: Terraform not initialized. Run 'terraform init' first."
    exit 1
}

# Get ACR details from Terraform
Write-Info "→ Getting ACR credentials..."
Push-Location $ScriptDir

try {
    $AcrLoginServer = terraform output -raw container_registry_login_server 2>$null
    $AcrUsername = terraform output -raw container_registry_admin_username 2>$null
    $AcrPassword = terraform output -raw container_registry_admin_password 2>$null

    if ([string]::IsNullOrEmpty($AcrLoginServer)) {
        Write-Error "ERROR: Could not get ACR details. Run 'terraform apply' first."
        exit 1
    }

    Write-Success "✓ ACR: $AcrLoginServer"

    # Setup custom build files
    $DockerIgnoreSrc = Join-Path $ScriptDir ".dockerignore.custom"
    $DockerIgnoreDst = Join-Path $ProjectRoot ".dockerignore.tmp"
    $DockerfileSrc = Join-Path $ScriptDir "Dockerfile.custom"
    $DockerfileDst = Join-Path $ProjectRoot "Dockerfile.tmp"

    Copy-Item $DockerIgnoreSrc $DockerIgnoreDst -Force
    Copy-Item $DockerfileSrc $DockerfileDst -Force

    # Login to ACR
    Write-Host ""
    Write-Info "→ Logging in to ACR..."

    $AcrPassword | docker login $AcrLoginServer -u $AcrUsername --password-stdin
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to login to ACR"
    }

    Write-Success "✓ Logged in"

    # Build the image
    Write-Host ""
    Write-Info "→ Building image: $AcrLoginServer/librechat:$ImageTag"

    Push-Location $ProjectRoot

    $GitHash = "latest"
    try {
        $GitHash = git rev-parse --short HEAD 2>$null
    } catch {
        # Git not available or not a git repo
    }

    docker build `
        -f Dockerfile.tmp `
        -t "$AcrLoginServer/librechat:$ImageTag" `
        -t "$AcrLoginServer/librechat:$GitHash" `
        .

    if ($LASTEXITCODE -ne 0) {
        throw "Build failed"
    }

    Write-Success "✓ Build complete"

    # Push the image
    Write-Host ""
    Write-Info "→ Pushing to ACR..."

    docker push "$AcrLoginServer/librechat:$ImageTag"
    if ($LASTEXITCODE -ne 0) {
        throw "Push failed"
    }

    if ($GitHash -ne "latest") {
        docker push "$AcrLoginServer/librechat:$GitHash"
    }

    Write-Host ""
    Write-Success "╔══════════════════════════════════════════╗"
    Write-Success "║         Build Complete! ✨                ║"
    Write-Success "╚══════════════════════════════════════════╝"
    Write-Host ""
    Write-Host "Image: " -NoNewline
    Write-Success "$AcrLoginServer/librechat:$ImageTag"
    Write-Host ""
    Write-Info "Next: terraform apply"
    Write-Host ""

} catch {
    Write-Error "ERROR: $_"
    exit 1
} finally {
    # Cleanup temporary files
    Pop-Location
    if (Test-Path $DockerIgnoreDst) {
        Remove-Item $DockerIgnoreDst -Force
    }
    if (Test-Path $DockerfileDst) {
        Remove-Item $DockerfileDst -Force
    }
    Pop-Location
}
