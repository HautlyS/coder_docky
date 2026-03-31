# Qoder CLI v0.1.37 - Docker Encapsulation

This Docker setup encapsulates Qoder CLI version **0.1.37** with all configurations preserved and auto-updates **permanently disabled**.

## 🎯 What This Does

- **Freezes Qoder CLI at v0.1.37** - No automatic or accidental updates
- **Preserves all your configurations** - MCP servers, preferences, projects
- **Isolated environment** - Clean, reproducible setup
- **Portable** - Can be deployed on any system with Docker
- **Backup support** - Easy data backup and restore

## 📦 Files Structure

```
qoder-docker/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Orchestration config
├── setup-docker-qoder.sh   # One-time setup script
├── run-qoder.sh           # Helper to run Qoder commands
├── start-qoder.sh         # Start container
├── stop-qoder.sh          # Stop container
├── backup-qoder-data.sh   # Backup your data
├── qodercli-package/      # Qoder CLI npm package (auto-generated)
└── qoder-config/          # Your configs (auto-generated)
```

## 🚀 Quick Start

### Prerequisites

- Docker installed
- Docker Compose installed
- Existing Qoder CLI installation (for migration)

### Installation

1. **Run the setup script:**
```bash
cd /home/ubuntu/qoder-docker
chmod +x setup-docker-qoder.sh
./setup-docker-qoder.sh
```

2. **Start the container:**
```bash
./start-qoder.sh
```

3. **Use Qoder CLI:**
```bash
./run-qoder.sh
# or
docker-compose exec qoder-cli qodercli
```

## 🔒 Auto-Update Disable Mechanisms

Multiple layers ensure updates never occur:

### 1. Application Level
```json
{
  "autoUpdates": false
}
```
Set in `.qoder.json` - tells Qoder not to check for updates

### 2. NPM Level
```
disable-renewal-updates=true
update-notifier=false
```
Configured in `/usr/local/etc/npmrc`

### 3. Environment Level
```bash
QODER_AUTO_UPDATES=false
QODER_DISABLE_UPDATE_CHECK=true
npm_config_update_notifier=false
```
Environment variables in Docker container

### 4. Isolation Level
The Docker container is a **closed system**:
- Fixed Node.js version (24.14.1)
- Fixed Qoder CLI version (0.1.37)
- No external update mechanisms can modify the binary
- Read-only package installation

## 🛠️ Usage

### Running Commands

```bash
# Interactive mode
./run-qoder.sh

# Direct command
./run-qoder.sh /help

# Enter container shell
docker-compose exec qoder-cli bash
```

### Managing Projects

Your projects are mounted in `./projects/`:

```bash
# All files in ./projects are accessible inside container
./projects/my-project/  # → /home/qoder/projects/my-project
```

### MCP Servers

MCP servers configured in `.qoder.json` work as usual. They run inside the container with network access.

## 💾 Backup & Restore

### Backup Data

```bash
./backup-qoder-data.sh
```

Creates timestamped backups in `./backups/`:
- `qoder-data.tar.gz` - Configuration and projects
- `qoder-cli-data.tar.gz` - CLI state and cache

### Restore Data

```bash
# Extract backup
cd backups/YYYYMMDD_HHMMSS
tar xzf qoder-data.tar.gz -C ~/.qoder/
tar xzf qoder-cli-data.tar.gz -C ~/.qoder-cli/
```

Or use Docker volumes:

```bash
docker run --rm \
  -v qoder-config-data:/data \
  -v $(pwd)/backups/restore:/backup \
  alpine tar xzf /backup/qoder-data.tar.gz -C /data
```

## 🔄 Migration from Native Installation

The setup script automatically:
1. Copies your current `.qoder.json`
2. Copies `.qoder/.config.json`
3. Disables auto-updates in configs
4. Preserves project histories and settings

**Manual migration** (if needed):

```bash
# Copy configs manually
cp ~/.qoder.json ./qoder-config/
cp -r ~/.qoder/.config.json ./qoder-config/.qoder/

# Re-run setup
./setup-docker-qoder.sh
```

## 🌐 Deploying to Other Systems

### Option 1: Build from Source

```bash
# On target system
git clone <your-repo>/qoder-docker
cd qoder-docker
./setup-docker-qoder.sh
```

### Option 2: Export Image

```bash
# On source system
docker save qoder-cli:0.1.37 | gzip > qoder-cli-0.1.37.tar.gz

# Transfer to target
scp qoder-cli-0.1.37.tar.gz user@target:

# On target system
docker load < qoder-cli-0.1.37.tar.gz

# Create docker-compose.yml and run
```

### Option 3: Docker Registry

```bash
# Push to registry
docker tag qoder-cli:0.1.37 registry.example.com/qoder-cli:0.1.37
docker push registry.example.com/qoder-cli:0.1.37

# On target system
docker pull registry.example.com/qoder-cli:0.1.37
```

## ⚙️ Advanced Configuration

### Increase Token Limits

Edit `qoder-config/.qoder.json`:

```json
{
  "maxOutputTokens": 32768,
  "modelLevel": "ultimate"
}
```

### Custom MCP Servers

Edit `qoder-config/.qoder.json` under `projects`:

```json
{
  "projects": {
    "/home/qoder/projects/my-project": {
      "mcpServers": {
        "playwright": {
          "command": "npx",
          "args": ["@playwright/mcp@latest"],
          "type": "stdio"
        }
      }
    }
  }
}
```

### Network Access

If MCP servers need host network access:

```yaml
# In docker-compose.yml
services:
  qoder-cli:
    network_mode: host
```

## 🐛 Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs qoder-cli

# Rebuild
docker-compose build --no-cache
```

### Permission issues

```bash
# Fix ownership
docker-compose exec qoder-cli chown -R qoder:qoder /home/qoder
```

### Can't access projects

Ensure `./projects` directory exists and has correct permissions:

```bash
mkdir -p ./projects
chmod 755 ./projects
```

### MCP servers not working

Check network configuration in `docker-compose.yml`. Some MCP servers may need `network_mode: host`.

## 📊 Version Information

| Component | Version |
|-----------|---------|
| Qoder CLI | 0.1.37 |
| Node.js   | 24.14.1 |
| Base Image | node:24.14.1-slim |

## 🔐 Security Notes

- SSH keys are mounted read-only (`:ro`)
- Container runs as non-root user (`qoder`)
- No privileged access required
- All data persisted in Docker volumes

## 📝 License

This Docker setup is for personal use. Qoder CLI remains subject to its own license terms.

## 🆘 Support

For Qoder-related issues: https://forum.qoder.com/

For Docker setup issues: Check logs and troubleshooting section above.

---

**Enjoy your stable, update-free Qoder CLI! 🎉**
