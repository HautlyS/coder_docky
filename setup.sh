#!/bin/bash
# Qoder CLI Docker Setup - Single Command Install
# Run: curl -sSL https://raw.githubusercontent.com/YOUR_USER/coder_docky/main/setup.sh | bash

set -e

echo "🚀 Qoder CLI Docker Setup"
echo "====================="

# Detect if we need sudo for apt commands
NEED_SUDO=""
if [ "$(id -u)" -ne 0 ] && ! id -nG | grep -qw "docker"; then
    if command -v sudo &> /dev/null; then
        NEED_SUDO="sudo"
        echo "  Using sudo for system commands..."
    else
        echo "WARNING: Running as non-root without sudo. Some commands may fail."
    fi
elif [ "$(id -u)" -eq 0 ]; then
    echo "  Running as root, no sudo needed"
fi

# Helper function for running apt commands
run_apt() {
    if [ -n "$NEED_SUDO" ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# CONFIG: Change these for your repo
REPO_URL="${REPO_URL:-https://raw.githubusercontent.com/HautlyS/coder_docky/master}"
TEMP_DIR="$(mktemp -d)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$TEMP_DIR"

echo "[1/5] Getting files..."

# Check if we're running locally (files already present)
if [ -f "$SCRIPT_DIR/Dockerfile" ] && [ -f "$SCRIPT_DIR/q" ]; then
    echo "  Using local files from $SCRIPT_DIR..."
    cp "$SCRIPT_DIR/Dockerfile" "$TEMP_DIR/Dockerfile"
    cp "$SCRIPT_DIR/q" "$TEMP_DIR/q"
    chmod +x "$TEMP_DIR/q"
else
    echo "  Downloading from: $REPO_URL/Dockerfile"
    curl -fsSL "$REPO_URL/Dockerfile" -o "$TEMP_DIR/Dockerfile" || { echo "ERROR: Failed to download Dockerfile from $REPO_URL/Dockerfile"; exit 1; }
    echo "  Downloading from: $REPO_URL/q"
    curl -fsSL "$REPO_URL/q" -o "$TEMP_DIR/q" || { echo "ERROR: Failed to download q from $REPO_URL/q"; exit 1; }
    chmod +x "$TEMP_DIR/q"
fi

# Verify downloads
if [ ! -s "$TEMP_DIR/Dockerfile" ] || [ ! -s "$TEMP_DIR/q" ]; then
    echo "ERROR: Downloaded files are empty"
    exit 1
fi

echo "  Downloaded: $(wc -l < "$TEMP_DIR/Dockerfile") lines in Dockerfile"

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "[2/5] Installing Docker..."
    run_apt apt-get update
    run_apt apt-get install -y ca-certificates curl gnupg lsb-release
    run_apt install -m 0755 -d /etc/apt/keyrings

    # Download Docker GPG key
    if [ ! -f /etc/apt/keyrings/docker.gpg ] || [ ! -s /etc/apt/keyrings/docker.gpg ]; then
        echo "  Downloading Docker GPG key..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.gpg 2>/dev/null && \
            run_apt gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.gpg 2>/dev/null && \
            rm -f /tmp/docker.gpg
    fi

    # Detect OS distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO=$(lsb_release -cs 2>/dev/null || echo "stable")
    fi

    # Use appropriate repo URL based on distro
    if [ "$DISTRO" = "debian" ]; then
        DOCKER_DISTRO="debian"
        DOCKER_SUITE=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    elif [ "$DISTRO" = "ubuntu" ]; then
        DOCKER_DISTRO="ubuntu"
        DOCKER_SUITE=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    else
        echo "WARNING: Unsupported distro '$DISTRO', trying debian/stable"
        DOCKER_DISTRO="debian"
        DOCKER_SUITE="stable"
    fi

    echo "  Detected OS: $DISTRO (suite: $DOCKER_SUITE)"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DOCKER_DISTRO $DOCKER_SUITE stable" | run_apt tee /etc/apt/sources.list.d/docker.list >/dev/null
    run_apt apt-get update
    run_apt apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
    echo "[2/5] Docker already installed"
fi

echo "[3/5] Checking Docker daemon..."

# Check if Docker daemon is running
if ! docker info &>/dev/null; then
    echo "  Docker daemon is not running. Attempting to start..."

    # Try to start dockerd
    if [ -x "$(command -v dockerd)" ]; then
        echo "  Starting Docker daemon..."
        dockerd &>/var/log/dockerd.log &
        DOCKERD_PID=$!

        # Wait for Docker daemon to be ready (up to 30 seconds)
        echo "  Waiting for Docker daemon to initialize..."
        for i in $(seq 1 30); do
            if docker info &>/dev/null; then
                echo "  Docker daemon is ready!"
                break
            fi
            if [ $i -eq 30 ]; then
                echo ""
                echo "ERROR: Docker daemon failed to start within 30 seconds."
                echo "  Check logs: cat /var/log/dockerd.log"
                echo ""
                echo "  Common issues:"
                echo "  - Running inside a container without privileged mode"
                echo "  - Missing iptables/netfilter permissions"
                echo "  - Try running with: --privileged --network=host"
                echo ""
                echo "  If you're in a sandbox/restricted environment, you may need"
                echo "  to build the image on a different machine and import it."
                exit 1
            fi
            sleep 1
        done
    else
        echo "ERROR: dockerd not found. Docker installation may be incomplete."
        exit 1
    fi
else
    echo "  Docker daemon is running"
fi

echo "[4/5] Building Docker image..."
cd "$TEMP_DIR"
if ! docker build -t qodercli-bug .; then
    echo ""
    echo "ERROR: Docker build failed."
    echo "  Check the Dockerfile for syntax errors or invalid base images."
    echo "  Current working directory: $TEMP_DIR"
    echo "  Files available:"
    ls -la "$TEMP_DIR"
    exit 1
fi

echo "[5/5] Installing q to PATH..."
mkdir -p "$HOME/.local/bin"
cp q "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/q"
ln -sf "$HOME/.local/bin/q" "$HOME/.local/bin/qodercli"

mkdir -p "$HOME/.qoder" "$HOME/.qoder-cli"

if ! grep -q "\.local/bin" "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo ""
echo "✅ Setup Complete!"
echo ""
echo "Usage:"
echo "  q                    # Interactive qodercli"
echo "  q --version          # Version check"
echo "  q 'your prompt'     # Run prompt"
echo ""
echo "Note: Run 'qodercli /login' once to login"