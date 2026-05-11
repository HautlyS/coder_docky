#!/bin/bash
# Qoder CLI Docker Setup - Single Command Install
# Run: curl -sSL https://raw.githubusercontent.com/YOUR_USER/coder_docky/main/setup.sh | bash

set -e

echo "🚀 Qoder CLI Docker Setup"
echo "====================="

# CONFIG: Change these for your repo
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/HautlyS/coder_docky/main}"
TEMP_DIR="$(mktemp -d)"
cd "$TEMP_DIR"

echo "[1/5] Downloading files..."
curl -sSL "$REPO_URL/Dockerfile" -o Dockerfile
curl -sSL "$REPO_URL/q" -o q
chmod +x q

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "[2/5] Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

echo "[3/5] Building Docker image..."
docker build -t qodercli-bug .

echo "[4/5] Installing q to PATH..."
mkdir -p "$HOME/.local/bin"
cp q "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/q"
ln -sf "$HOME/.local/bin/q" "$HOME/.local/bin/qodercli"

mkdir -p "$HOME/.qoder" "$HOME/.qoder-cli"

if ! grep -q "\.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "[5/5] Done!"
source "$HOME/.bashrc"
rm -rf "$TEMP_DIR"

echo ""
echo "✅ Setup Complete!"
echo ""
echo "Usage:"
echo "  q                    # Interactive qodercli"
echo "  q --version          # Version check"
echo "  q 'your prompt'     # Run prompt"
echo ""
echo "Note: Run 'qodercli /login' once to login"