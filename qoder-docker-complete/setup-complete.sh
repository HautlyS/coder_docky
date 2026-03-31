#!/bin/bash

# Complete Development Environment Setup Script
# Installs Docker, builds the complete environment with Qoder CLI, Kiro CLI, and all tools

set -e

echo "🚀 Setting up Complete Development Environment"
echo "=============================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if command -v docker &> /dev/null && docker compose version &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Docker if needed
install_docker_if_needed() {
    if check_docker; then
        print_info "Docker is already installed ✅"
        docker --version
        docker compose version
        return 0
    fi

    print_warn "Docker not found. Installing Docker..."
    
    # Update and install prerequisites
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    # Add Docker's GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Add user to docker group
    sudo usermod -aG docker $USER

    # Start Docker service
    sudo service docker start || true

    print_info "Docker installed successfully! ✅"
    print_warn "Remember to run: newgrp docker"
}

# Ask for GitHub token
get_github_token() {
    echo ""
    print_info "GitHub Authentication Setup"
    echo "----------------------------------"
    echo ""
    echo "Your GitHub token will be used to:"
    echo "  • Clone repositories"
    echo "  • Configure Git authentication"
    echo "  • Enable MCP servers"
    echo ""
    echo "You can skip this and set it later in .env file"
    echo ""
    read -p "Enter your GitHub token (or press Enter to skip): " -s GITHUB_TOKEN_INPUT
    echo ""
    
    if [ -n "$GITHUB_TOKEN_INPUT" ]; then
        echo "GITHUB_TOKEN=$GITHUB_TOKEN_INPUT" > .env
        print_info "GitHub token saved to .env ✅"
    else
        print_warn "Skipping GitHub token setup (you can add it later)"
        echo "# GITHUB_TOKEN=your_token_here" > .env
    fi
}

# Build Docker image
build_image() {
    print_step "Building Docker image (this may take 5-10 minutes)..."
    docker build -t psiu-dev:complete .
    
    if [ $? -eq 0 ]; then
        print_info "Docker image built successfully! ✅"
    else
        print_error "Failed to build Docker image ❌"
        exit 1
    fi
}

# Create helper scripts
create_helper_scripts() {
    print_info "Creating helper scripts..."

    # Start script
    cat > start.sh << 'EOF'
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose up -d
echo "✅ Development environment started!"
echo "Run './enter.sh' to enter the container"
EOF
    chmod +x start.sh

    # Enter script
    cat > enter.sh << 'EOF'
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose exec dev-environment bash
EOF
    chmod +x enter.sh

    # Stop script
    cat > stop.sh << 'EOF'
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose down
echo "Development environment stopped!"
EOF
    chmod +x stop.sh

    # Restart script
    cat > restart.sh << 'EOF'
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose restart
echo "Development environment restarted!"
EOF
    chmod +x restart.sh

    # Rebuild script
    cat > rebuild.sh << 'EOF'
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose build --no-cache
echo "Image rebuilt!"
EOF
    chmod +x rebuild.sh

    # Backup script
    cat > backup.sh << 'EOF'
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Backing up development data..."
docker run --rm \
    -v dev-data:/data/source:ro \
    -v "$BACKUP_DIR:/data/backup" \
    alpine tar czf /data/backup/qoder-data.tar.gz -C /data/source .

docker run --rm \
    -v dev-cli-data:/data/source:ro \
    -v "$BACKUP_DIR:/data/backup" \
    alpine tar czf /data/backup/qoder-cli-data.tar.gz -C /data/source .

echo "✅ Backup created in: $BACKUP_DIR"
EOF
    chmod +x backup.sh

    # Setup MCP servers script (Basic)
    cat > setup-mcp.sh << 'EOF'
#!/bin/bash
echo "Setting up basic MCP servers..."

# Wait for container to be ready
sleep 2

# Setup Playwright MCP for Kiro
echo "Setting up Playwright MCP for Kiro..."
docker compose exec dev-environment bash -c '
PLAYWRIGHT_MCP_PATH=$(npm root -g)/../bin/playwright-mcp
kiro-cli mcp remove --name playwright 2>/dev/null || true
kiro-cli mcp add --name playwright --command "$PLAYWRIGHT_MCP_PATH"
'

# Setup Supabase MCP for Kiro
echo "Setting up Supabase MCP for Kiro..."
docker compose exec dev-environment bash -c '
kiro-cli mcp add --name supabase --url "https://mcp.supabase.com/mcp"
'

# Setup Playwright MCP for Qoder
echo "Setting up Playwright MCP for Qoder..."
docker compose exec dev-environment bash -c '
qodercli mcp add playwright "npm install -g @playwright/mcp && playwright-mcp"
'

# Setup Supabase MCP for Qoder
echo "Setting up Supabase MCP for Qoder..."
docker compose exec dev-environment bash -c '
qodercli mcp add supabase "https://mcp.supabase.com/mcp"
'

echo "✅ Basic MCP servers configured!"
echo ""
echo "🌟 For advanced MCP management, use:"
echo "   ./advanced-mcp-manager.sh"
EOF
    chmod +x setup-mcp.sh

    # Clone project script (legacy - now using dynamic)
    cat > clone-project.sh << 'EOF'
#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")"
echo "Cloning single project (legacy mode)..."
echo ""
echo "🌟 For dynamic multi-repo cloning, use:"
echo "   ./clone-repos.sh"
echo ""
docker compose exec dev-environment bash -c '
cd /home/workspace
if [ ! -d "web" ]; then
    git clone https://github.com/psiuproject/web
    cd web
    pnpm install
    echo "✅ Project cloned and dependencies installed!"
else
    echo "⚠️  Project already exists"
fi
'
EOF
    chmod +x clone-project.sh

    # Dynamic repo cloning script
    cp ./scripts/clone-repos.sh clone-repos.sh
    chmod +x clone-repos.sh

    # Advanced MCP Manager
    cp ./scripts/mcp-manager.sh advanced-mcp-manager.sh
    chmod +x advanced-mcp-manager.sh

    # Skills Manager
    cp ./scripts/skills-manager.sh skills-manager.sh
    chmod +x skills-manager.sh
EOF
    chmod +x clone-project.sh

    print_info "Helper scripts created:"
    echo ""
    echo "🔧 Core Scripts:"
    echo "  ./start.sh              - Start the environment"
    echo "  ./enter.sh              - Enter the container"
    echo "  ./stop.sh               - Stop the environment"
    echo "  ./restart.sh            - Restart the environment"
    echo "  ./rebuild.sh            - Rebuild the image"
    echo "  ./backup.sh             - Backup your data"
    echo ""
    echo "🌟 Enhanced Features:"
    echo "  ./clone-repos.sh        - Dynamic GitHub repo cloning (multi-select)"
    echo "  ./advanced-mcp-manager.sh - MCP marketplace & management"
    echo "  ./skills-manager.sh     - Skills/agents manager"
    echo "  ./setup-mcp.sh          - Quick MCP setup (basic)"
    echo "  ./clone-project.sh      - Clone single project (legacy)"
}

# Main execution
main() {
    echo ""
    print_step "Step 1/5: Checking Docker installation..."
    install_docker_if_needed

    echo ""
    print_step "Step 2/5: GitHub Authentication"
    get_github_token

    echo ""
    print_step "Step 3/5: Building Docker image..."
    build_image

    echo ""
    print_step "Step 4/5: Creating helper scripts..."
    create_helper_scripts

    echo ""
    print_step "Step 5/5: Starting environment..."
    docker compose up -d

    echo ""
    echo "=============================================="
    print_info "Setup Complete! ✅"
    echo "=============================================="
    echo ""
    echo "📦 Your complete development environment includes:"
    echo "  ✓ Qoder CLI v0.1.37 (auto-updates disabled)"
    echo "  ✓ Kiro CLI"
    echo "  ✓ Kilocode CLI"
    echo "  ✓ Node.js 24"
    echo "  ✓ pnpm"
    echo "  ✓ Google Chrome"
    echo "  ✓ Playwright MCP"
    echo "  ✓ Supabase MCP"
    echo "  ✓ Git with GitHub integration"
    echo ""
    echo "🚀 Next steps:"
    echo "  1. Enter container:       ./enter.sh"
    echo "  2. Clone repositories:    ./clone-repos.sh (dynamic multi-select!)"
    echo "  3. Setup basic MCPs:      ./setup-mcp.sh"
    echo ""
    echo "🌟 Enhanced Features:"
    echo "  • Browse & clone multiple GitHub repos: ./clone-repos.sh"
    echo "  • MCP marketplace manager:              ./advanced-mcp-manager.sh"
    echo "  • Skills/agents manager:                ./skills-manager.sh"
    echo ""
    echo "🔧 Useful commands:"
    echo "  ./start.sh              - Start environment"
    echo "  ./stop.sh               - Stop environment"
    echo "  ./backup.sh             - Backup data"
    echo ""
    echo "📝 All your work is saved in: ./workspace/"
    echo ""
    echo "Enjoy your enhanced, encapsulated development environment! 🎉"
}

# Run main function
main
