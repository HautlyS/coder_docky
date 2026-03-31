#!/bin/bash

# Docker & Docker Compose Installation Script for Ubuntu WSL
# This script installs Docker Desktop with WSL2 support

set -e

echo "🐳 Installing Docker for Ubuntu WSL"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    print_info "WSL detected - proceeding with WSL-compatible installation"
else
    print_warn "Not running on WSL, but continuing anyway"
fi

# Step 1: Update package list
print_info "Step 1/5: Updating package list..."
sudo apt-get update

# Step 2: Install prerequisites
print_info "Step 2/5: Installing prerequisites..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Step 3: Add Docker's official GPG key
print_info "Step 3/5: Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Step 4: Set up the repository
print_info "Step 4/5: Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 5: Install Docker Engine
print_info "Step 5/5: Installing Docker Engine and Compose..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (avoid sudo)
print_info "Adding user to docker group..."
sudo usermod -aG docker $USER

# Start Docker service
print_info "Starting Docker service..."
sudo service docker start || true

echo ""
echo "=================================================="
print_info "Docker installation complete! ✅"
echo "=================================================="
echo ""
print_warn "IMPORTANT: You need to log out and log back in for group changes to take effect"
echo ""
echo "Or run this command to apply immediately:"
echo "  newgrp docker"
echo ""
echo "Then verify installation:"
echo "  docker --version"
echo "  docker compose version"
echo ""
echo "After that, run the Qoder setup:"
echo "  cd /home/ubuntu/qoder-docker"
echo "  ./setup-docker-qoder.sh"
echo ""
