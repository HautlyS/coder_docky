#!/bin/bash
# Qoder CLI Docker Setup - Single Command Install
# Run: curl -sSL https://... | bash  OR  ./setup.sh

set -e

echo "🚀 Qoder CLI Docker Setup"
echo "====================="

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "[1/4] Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[2/4] Building Docker image..."
docker build -t qodercli-bug .

echo "[3/4] Installing q to PATH..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/q" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/q"
ln -sf "$HOME/.local/bin/q" "$HOME/.local/bin/qodercli"

# Create config directories
mkdir -p "$HOME/.qoder" "$HOME/.qoder-cli"

# Add to PATH if not already
if ! grep -q "\.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "[4/4] Done!"
source "$HOME/.bashrc"

echo ""
echo "✅ Setup Complete!"
echo ""
echo "Usage:"
echo "  q                    # Interactive qodercli"
echo "  q --version          # Version check"
echo "  q 'your prompt'     # Run prompt"
echo ""
echo "Note: Run 'qodercli /login' once to login, config persists in ~/.qoder/"