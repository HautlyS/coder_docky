# 🚀 Complete Development Environment - Docker Setup

## 📦 What's Included

This complete development environment includes **everything** from your installation script:

### Core Tools
- ✅ **Qoder CLI v0.1.37** (auto-updates disabled)
- ✅ **Kiro CLI** (with MCP support)
- ✅ **Kilocode CLI**
- ✅ **Node.js 24** (via nvm)
- ✅ **pnpm** (latest)
- ✅ **Git** with GitHub integration

### MCP Servers
- ✅ **Playwright MCP** (globally installed)
- ✅ **Supabase MCP** (HTTP endpoint)

### System Dependencies
- ✅ **Google Chrome** (for Playwright)
- ✅ **GitHub CLI (gh)**
- ✅ **unzip, curl, wget**
- ✅ **libasound2t64** (audio support)
- ✅ **ripgrep, fd-find, jq**

---

## ⚡ Quick Start (5 minutes)

### 1. Run the Setup Script

```bash
cd /home/ubuntu/qoder-docker-complete
chmod +x setup-complete.sh
./setup-complete.sh
```

The script will:
- Install Docker if needed
- Ask for your GitHub token (optional)
- Build the complete Docker image
- Create helper scripts
- Start the environment

### 2. Enter the Container

```bash
./enter.sh
```

### 3. Setup MCP Servers

```bash
./setup-mcp.sh
```

### 4. Clone Your Project

```bash
./clone-project.sh
```

---

## 🔧 Helper Scripts

| Script | Purpose | Command |
|--------|---------|---------|
| `start.sh` | Start environment | `./start.sh` |
| `enter.sh` | Enter container | `./enter.sh` |
| `stop.sh` | Stop environment | `./stop.sh` |
| `restart.sh` | Restart | `./restart.sh` |
| `rebuild.sh` | Rebuild image | `./rebuild.sh` |
| `backup.sh` | Backup data | `./backup.sh` |
| `setup-mcp.sh` | Configure MCP servers | `./setup-mcp.sh` |
| `clone-project.sh` | Clone project repo | `./clone-project.sh` |

---

## 🎯 Usage Examples

### Using Qoder CLI

```bash
# Enter container
./enter.sh

# Use Qoder
qodercli

# Or with arguments
qodercli /help
```

### Using Kiro CLI

```bash
# Enter container
./enter.sh

# Use Kiro
kiro-cli

# Add MCP server
kiro-cli mcp add playwright --command playwright-mcp
```

### Working on Projects

All projects are in `./workspace/`:

```bash
# Access from host
cd /home/ubuntu/qoder-docker-complete/workspace

# Access from container
./enter.sh
cd /home/workspace
```

---

## 🔐 Auto-Updates Disabled

Just like the previous setup, auto-updates are disabled at multiple levels:

1. **Qoder CLI**: `"autoUpdates": false`
2. **NPM**: `update-notifier=false`
3. **Environment**: `QODER_AUTO_UPDATES=false`
4. **Container**: Frozen versions

---

## 🌐 Deploy to Other Systems

### Export Docker Image

```bash
docker save psiu-dev:complete | gzip > psiu-dev-complete.tar.gz

# On target system
docker load < psiu-dev-complete.tar.gz
```

### Copy Entire Directory

```bash
# Copy qoder-docker-complete/ to another system
# Run ./setup-complete.sh there
```

---

## 📁 Directory Structure

```
qoder-docker-complete/
├── Dockerfile              # Complete environment definition
├── docker-compose.yml      # Orchestration config
├── setup-complete.sh       # Main setup script
├── start.sh               # Start container
├── enter.sh               # Enter container
├── stop.sh                # Stop container
├── setup-mcp.sh           # Configure MCP servers
├── clone-project.sh       # Clone project repo
├── backup.sh              # Backup data
├── rebuild.sh             # Rebuild image
└── workspace/             # Your projects (mounted)
```

---

## 🔍 Verification

### Check All Tools

```bash
./enter.sh

# Inside container:
qodercli --version        # Should show 0.1.37
kiro-cli --version        # Should be installed
node -v                   # Should show v24.x.x
pnpm -v                   # Should show version
google-chrome --version   # Should be installed
```

### Check MCP Servers

```bash
# For Qoder
qodercli mcp list

# For Kiro
kiro-cli mcp list
```

---

## 💾 Backup Your Data

```bash
# Automatic backup
./backup.sh

# Creates timestamped backup in ./backups/
# Includes: .qoder, .qoder-cli, configurations
```

---

## 🛠️ Troubleshooting

### Docker Not Found

```bash
# Install Docker manually
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

### Permission Denied

```bash
# Fix permissions
sudo chown -R $USER:$USER ./workspace
```

### Chrome Issues

```bash
# Reinstall Chrome in container
docker compose exec dev-environment apt-get update
docker compose exec dev-environment apt-get install -y google-chrome-stable
```

### MCP Servers Not Working

```bash
# Re-run MCP setup
./setup-mcp.sh
```

---

## 📊 Technical Specifications

| Component | Version | Notes |
|-----------|---------|-------|
| Base Image | node:24.14.1-slim | Official Node image |
| Qoder CLI | 0.1.37 | Frozen, no updates |
| Kiro CLI | Latest | From cli.kiro.dev |
| Kilocode | Latest | From npm |
| Node.js | 24.x | Via nvm |
| pnpm | Latest | Via corepack |
| Chrome | Latest | From Google |
| Git | System | Configured with your info |

---

## 🎓 What This Replaces

This Docker setup replaces ALL these manual steps:

```bash
# You DON'T need to run any of these anymore!
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
nvm install 24
corepack enable pnpm
pnpm setup
pnpm add -g @kilocode/cli
npm install -g @qoder-ai/qodercli
apt install unzip gh libasound2t64
wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i /tmp/chrome.deb
curl -fsSL https://cli.kiro.dev/install | bash
gh auth login
git clone https://github.com/psiuproject/web
pnpm i
npm install -g @playwright/mcp
kiro-cli mcp add playwright
kiro-cli mcp add supabase
qodercli mcp add playwright
qodercli mcp add supabase
```

**Everything is automated!** ✅

---

## 🔗 Related Documentation

- [Original Qoder Docker Setup](../qoder-docker/README.md) - Basic Qoder-only setup
- [Auto-Update Analysis](../qoder-docker/AUTO_UPDATE_ANALYSIS.md) - Technical details
- [Quick Start Guide](../qoder-docker/QUICKSTART.md) - Installation guide

---

## 🆘 Support

- Qoder Forum: https://forum.qoder.com/
- Kiro Docs: https://kiro.dev/docs
- Local logs: `~/.qoder/logs/`

---

**Enjoy your complete, encapsulated development environment! 🎉**

*Last updated: 2026-03-31*
