#!/bin/bash

# Qoder CLI v0.1.37 - Docker Setup Script
# This script prepares all necessary files and builds the Docker container

set -e

echo "🔧 Qoder CLI v0.1.37 - Docker Encapsulation Setup"
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Create directories
print_info "Step 1/6: Creating directory structure..."
mkdir -p "$SCRIPT_DIR/qodercli-package"
mkdir -p "$SCRIPT_DIR/qoder-config"
mkdir -p "$SCRIPT_DIR/projects"

# Step 2: Copy Qoder CLI npm package
print_info "Step 2/6: Copying Qoder CLI package files..."
if [ -d "/home/ubuntu/.nvm/versions/node/v24.14.1/lib/node_modules/@qoder-ai/qodercli" ]; then
    cp -r /home/ubuntu/.nvm/versions/node/v24.14.1/lib/node_modules/@qoder-ai/qodercli/* \
          "$SCRIPT_DIR/qodercli-package/"
    print_info "Qoder CLI package copied successfully"
else
    print_error "Qoder CLI installation not found!"
    echo "Please ensure Qoder CLI is installed at the expected location."
    exit 1
fi

# Step 3: Backup configuration files
print_info "Step 3/6: Backing up Qoder configuration files..."
if [ -f "/home/ubuntu/.qoder.json" ]; then
    cp /home/ubuntu/.qoder.json "$SCRIPT_DIR/qoder-config/"
    print_info ".qoder.json backed up"
else
    print_warn ".qoder.json not found, will create default"
fi

if [ -f "/home/ubuntu/.qoder/.config.json" ]; then
    mkdir -p "$SCRIPT_DIR/qoder-config/.qoder"
    cp /home/ubuntu/.qoder/.config.json "$SCRIPT_DIR/qoder-config/.qoder/"
    print_info ".qoder/.config.json backed up"
else
    print_warn ".qoder/.config.json not found, will create default"
    mkdir -p "$SCRIPT_DIR/qoder-config/.qoder"
fi

# Step 4: Disable auto-updates in config
print_info "Step 4/6: Disabling auto-updates in configuration..."

# Create or update .qoder.json with auto-updates disabled
if [ -f "$SCRIPT_DIR/qoder-config/.qoder.json" ]; then
    # Use jq to safely modify JSON
    if command -v jq &> /dev/null; then
        jq '.autoUpdates = false' "$SCRIPT_DIR/qoder-config/.qoder.json" > "$SCRIPT_DIR/qoder-config/.qoder.json.tmp" \
            && mv "$SCRIPT_DIR/qoder-config/.qoder.json.tmp" "$SCRIPT_DIR/qoder-config/.qoder.json"
    else
        # Fallback: simple sed replacement
        sed -i 's/"autoUpdates": true/"autoUpdates": false/g' "$SCRIPT_DIR/qoder-config/.qoder.json"
    fi
    print_info "Auto-updates disabled in .qoder.json"
else
    # Create minimal config with updates disabled
    cat > "$SCRIPT_DIR/qoder-config/.qoder.json" << 'EOF'
{
  "autoCompactEnabled": true,
  "todoFeatureEnabled": true,
  "checkpointingEnabled": true,
  "verbose": false,
  "autoUpdates": false,
  "theme": "Qoder",
  "autoConnectIde": false,
  "maxOutputTokens": 16384,
  "modelLevel": "ultimate",
  "projects": {}
}
EOF
    print_info "Created default .qoder.json with auto-updates disabled"
fi

# Ensure .qoder/.config.json exists
if [ ! -f "$SCRIPT_DIR/qoder-config/.qoder/.config.json" ]; then
    cat > "$SCRIPT_DIR/qoder-config/.qoder/.config.json" << 'EOF'
{
  "region_config": {
    "preferredInferenceNode": {
      "endpoint": "https://api1.qoder.sh",
      "latency": 0
    },
    "fallbackIpMap": {}
  }
}
EOF
    print_info "Created default .qoder/.config.json"
fi

# Step 5: Build Docker image
print_info "Step 5/6: Building Docker image..."
docker build -t qoder-cli:0.1.37 "$SCRIPT_DIR"

if [ $? -eq 0 ]; then
    print_info "Docker image built successfully!"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Step 6: Create helper scripts
print_info "Step 6/6: Creating helper scripts..."

# Create run script
cat > "$SCRIPT_DIR/run-qoder.sh" << 'RUNEOF'
#!/bin/bash
# Run Qoder CLI in Docker
cd "$(dirname "${BASH_SOURCE[0]}")"
docker-compose exec qoder-cli qodercli "$@"
RUNEOF
chmod +x "$SCRIPT_DIR/run-qoder.sh"

# Create start script
cat > "$SCRIPT_DIR/start-qoder.sh" << 'STARTEOF'
#!/bin/bash
# Start Qoder CLI container
cd "$(dirname "${BASH_SOURCE[0]}")"
docker-compose up -d
echo "Qoder CLI container started!"
echo "Run './run-qoder.sh' to use Qoder CLI"
STARTEOF
chmod +x "$SCRIPT_DIR/start-qoder.sh"

# Create stop script
cat > "$SCRIPT_DIR/stop-qoder.sh" << 'STOPEOF'
#!/bin/bash
# Stop Qoder CLI container
cd "$(dirname "${BASH_SOURCE[0]}")"
docker-compose down
echo "Qoder CLI container stopped!"
STOPEOF
chmod +x "$SCRIPT_DIR/stop-qoder.sh"

# Create backup script
cat > "$SCRIPT_DIR/backup-qoder-data.sh" << 'BACKUPEOF'
#!/bin/bash
# Backup Qoder data from Docker volumes
cd "$(dirname "${BASH_SOURCE[0]}")"
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

docker run --rm \
    -v qoder-config-data:/data/source:ro \
    -v "$BACKUP_DIR:/data/backup" \
    alpine tar czf /data/backup/qoder-data.tar.gz -C /data/source .

docker run --rm \
    -v qoder-cli-data:/data/source:ro \
    -v "$BACKUP_DIR:/data/backup" \
    alpine tar czf /data/backup/qoder-cli-data.tar.gz -C /data/source .

echo "Backup created in: $BACKUP_DIR"
BACKUPEOF
chmod +x "$SCRIPT_DIR/backup-qoder-data.sh"

print_info "Helper scripts created:"
echo "  - run-qoder.sh       : Run Qoder CLI commands"
echo "  - start-qoder.sh     : Start the container"
echo "  - stop-qoder.sh      : Stop the container"
echo "  - backup-qoder-data.sh: Backup your data"

echo ""
echo "=================================================="
print_info "Setup Complete! ✅"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  1. Start the container: ./start-qoder.sh"
echo "  2. Run Qoder CLI: ./run-qoder.sh"
echo "  3. Or enter container: docker-compose exec qoder-cli bash"
echo ""
echo "To disable auto-updates permanently, the following are configured:"
echo "  ✓ autoUpdates: false in .qoder.json"
echo "  ✓ npm update-notifier disabled"
echo "  ✓ Isolated Docker environment"
echo ""
echo "Your Qoder CLI v0.1.37 is now encapsulated and protected! 🎉"
