# 🚀 Quick Start Guide - Qoder CLI Docker Encapsulation

## Overview

This guide will help you encapsulate Qoder CLI v0.1.37 in a Docker container with auto-updates permanently disabled.

---

## ⚡ Fast Track (5 minutes)

### Step 1: Install Docker (if not installed)

```bash
cd /home/ubuntu/qoder-docker
./install-docker.sh
```

**After installation, either:**
- Log out and log back in, **OR**
- Run: `newgrp docker`

### Step 2: Run Qoder Setup

```bash
./setup-docker-qoder.sh
```

### Step 3: Start Using

```bash
./start-qoder.sh
./run-qoder.sh
```

**Done!** ✅ You're now running Qoder CLI v0.1.37 in an isolated container.

---

## 📋 Detailed Installation

### Prerequisites Check

```bash
# Check if Docker is installed
docker --version

# Check if Docker Compose is available
docker compose version

# Verify WSL environment
uname -r  # Should contain "microsoft" for WSL
```

If Docker is **not** installed, proceed with installation below.

---

### Option A: Automatic Installation (Recommended)

```bash
cd /home/ubuntu/qoder-docker
./install-docker.sh
```

This script will:
1. Install Docker Engine
2. Install Docker Compose plugin
3. Add your user to the docker group
4. Start Docker service

**After script completes:**
```bash
# Apply group changes without logout
newgrp docker

# Verify
docker --version
```

---

### Option B: Manual Installation

If you prefer manual control:

```bash
# 1. Update packages
sudo apt-get update

# 2. Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 3. Add Docker's GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Set up repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# 5. Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 6. Add user to docker group
sudo usermod -aG docker $USER

# 7. Start Docker
sudo service docker start
```

Then logout/login or run `newgrp docker`.

---

## 🔧 Setting Up Qoder CLI

Once Docker is ready:

```bash
cd /home/ubuntu/qoder-docker
./setup-docker-qoder.sh
```

**What this does:**
1. ✅ Creates directory structure
2. ✅ Copies Qoder CLI package (v0.1.37)
3. ✅ Backs up your configurations
4. ✅ Disables auto-updates
5. ✅ Builds Docker image
6. ✅ Creates helper scripts

**Expected output:**
```
Setup Complete! ✅

Next steps:
  1. Start the container: ./start-qoder.sh
  2. Run Qoder CLI: ./run-qoder.sh
```

---

## 🎯 Daily Usage

### Starting Qoder

```bash
# Start the container (first time or after stop)
./start-qoder.sh
```

### Running Qoder Commands

```bash
# Interactive mode
./run-qoder.sh

# Or specific command
./run-qoder.sh /help

# Direct docker command
docker compose exec qoder-cli qodercli
```

### Stopping Qoder

```bash
./stop-qoder.sh
```

---

## 📁 Working with Projects

Your projects are in `./projects/`:

```bash
# Create/access projects
cd /home/ubuntu/qoder-docker/projects
mkdir my-new-project
cd my-new-project

# Then in Qoder
./run-qoder.sh
# Navigate to /home/qoder/projects/my-new-project
```

All files in `./projects` are automatically available inside the container at `/home/qoder/projects`.

---

## 💾 Backup Your Data

### Automatic Backup

```bash
./backup-qoder-data.sh
```

Creates timestamped backup in `./backups/`

### Manual Backup

```bash
# Export all Qoder data
docker compose exec qoder-cli tar czf /tmp/qoder-backup.tar.gz /home/qoder/.qoder

# Copy to host
docker compose cp qoder-cli:/tmp/qoder-backup.tar.gz ./qoder-backup.tar.gz
```

---

## 🔍 Verification

### Verify Auto-Updates Disabled

```bash
# Check configuration
docker compose exec qoder-cli grep autoUpdates /home/qoder/.qoder.json
# Output: "autoUpdates": false

# Check environment
docker compose exec qoder-cli env | grep -i QODER
# Should show: QODER_AUTO_UPDATES=false
```

### Verify Version

```bash
docker compose exec qoder-cli qodercli --version
# Should show: 0.1.37
```

---

## 🌐 Deploying to Another System

### Method 1: Export Docker Image

```bash
# On source system
docker save qoder-cli:0.1.37 | gzip > qoder-cli-0.1.37.tar.gz

# Transfer file
scp qoder-cli-0.1.37.tar.gz user@target-system:

# On target system
docker load < qoder-cli-0.1.37.tar.gz

# Copy setup files
scp -r /home/ubuntu/qoder-docker/*.sh user@target-system:qoder-docker/
scp /home/ubuntu/qoder-docker/docker-compose.yml user@target-system:qoder-docker/

# On target: run setup
cd qoder-docker
./setup-docker-qoder.sh  # Will skip build if image exists
```

### Method 2: Build from Scratch

```bash
# Clone or copy entire qoder-docker directory
git clone <your-repo> qoder-docker
cd qoder-docker

# Run setup
./setup-docker-qoder.sh
```

---

## 🛠️ Troubleshooting

### Docker Command Not Found

```bash
# Add docker to PATH (temporary)
export PATH=$PATH:/usr/bin

# Or use full path
/usr/bin/docker --version

# Permanent fix: add to ~/.bashrc
echo 'export PATH=$PATH:/usr/bin' >> ~/.bashrc
source ~/.bashrc
```

### Permission Denied

```bash
# Re-add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Container Won't Start

```bash
# Check logs
docker compose logs

# Rebuild
docker compose build --no-cache
docker compose up -d
```

### Can't Access Projects

```bash
# Ensure directory exists
mkdir -p ./projects

# Check permissions
chmod 755 ./projects
```

---

## 📊 What's Included

| Component | Status | Notes |
|-----------|--------|-------|
| Qoder CLI | ✅ v0.1.37 | Frozen, no updates |
| Node.js | ✅ v24.14.1 | Matching your system |
| Auto-updates | ❌ Disabled | Multiple layers |
| MCP Servers | ✅ Supported | Playwright, Supabase, etc. |
| Git Integration | ✅ Supported | Mount SSH keys |
| Project History | ✅ Preserved | All your data |
| Configurations | ✅ Preserved | All settings |

---

## 🎓 Helper Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `install-docker.sh` | Install Docker | `./install-docker.sh` |
| `setup-docker-qoder.sh` | Full setup | `./setup-docker-qoder.sh` |
| `start-qoder.sh` | Start container | `./start-qoder.sh` |
| `run-qoder.sh` | Run Qoder | `./run-qoder.sh [args]` |
| `stop-qoder.sh` | Stop container | `./stop-qoder.sh` |
| `backup-qoder-data.sh` | Backup data | `./backup-qoder-data.sh` |

---

## 🔐 Security Notes

- Container runs as non-root user (`qoder`)
- SSH keys mounted read-only
- No privileged access required
- All data in Docker volumes (isolated)

---

## 📞 Need Help?

### Check These First

1. **Docker status**: `docker ps`
2. **Container logs**: `docker compose logs qoder-cli`
3. **Configuration**: `cat qoder-config/.qoder.json`
4. **Helper scripts**: Run with `--help` or check source

### Resources

- Qoder Forum: https://forum.qoder.com/
- Docker Docs: https://docs.docker.com/
- Local logs: `~/.qoder/logs/`

---

## ✅ Success Checklist

Before considering setup complete:

- [ ] Docker installed and running
- [ ] `docker --version` works
- [ ] `docker compose version` works
- [ ] Setup script completed without errors
- [ ] Container starts successfully
- [ ] Qoder CLI runs inside container
- [ ] Auto-updates confirmed disabled
- [ ] Projects accessible
- [ ] Backup created

---

**You're all set! Enjoy your stable, encapsulated Qoder CLI v0.1.37! 🎉**

---

*Last updated: 2026-03-31*
*Version: 0.1.37*
