# 🚀 Enhanced Development Environment - Complete Guide

## 🎉 What's New (v2.0)

Your development environment just got **WAY** more powerful! Here are the new features:

### 🔥 New Capabilities

1. **Dynamic GitHub Repository Cloning** 📦
   - Automatically loads ALL your GitHub repositories
   - Multi-select with interactive UI (fzf)
   - Batch clone multiple repos at once
   - Auto-install dependencies (pnpm/npm/yarn)
   - Preview repo details before cloning

2. **Advanced MCP Server Manager** 🌐
   - Browse popular MCP servers
   - Search NPM for new MCP servers
   - One-click install & configure
   - Support for HTTP and command-based MCPs
   - Backup/restore MCP configurations
   - Update all MCPs automatically

3. **Skills & Agents Manager** 🧠
   - Browse popular AI skills/agents
   - Search and install from NPM
   - Try skills with npx before installing
   - Configure for Qoder, Kiro, and Kilocode
   - Manage skill configurations
   - Backup skills setup

---

## 📋 Complete Script Reference

### Core Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `start.sh` | Start Docker container | `./start.sh` |
| `enter.sh` | Enter container shell | `./enter.sh` |
| `stop.sh` | Stop container | `./stop.sh` |
| `restart.sh` | Restart container | `./restart.sh` |
| `rebuild.sh` | Rebuild Docker image | `./rebuild.sh` |
| `backup.sh` | Backup all data | `./backup.sh` |

### 🌟 Enhanced Feature Scripts

#### 1. Dynamic Repository Cloning

```bash
./clone-repos.sh
```

**Features:**
- ✅ Lists ALL your GitHub repos
- ✅ Shows stars, description, last update
- ✅ Multi-select with Tab/Ctrl-Space
- ✅ Preview repo details before cloning
- ✅ Auto-installs dependencies
- ✅ Skips already-cloned repos

**Interface:**
```
📋 Select repositories to clone (use Tab to select multiple, Enter to confirm):
─────────────────────────────────────────────────────────────────────────────
  1. web            Main website project (15 ⭐)
  2. api            Backend API service (8 ⭐)
  3. mobile         Mobile app (23 ⭐)
  ...
```

**Controls:**
- `Tab` or `Ctrl-Space`: Toggle selection
- `Ctrl-A`: Select all
- `Ctrl-D`: Deselect all
- `Enter`: Confirm and clone

---

#### 2. Advanced MCP Manager

```bash
./advanced-mcp-manager.sh
```

**Menu Options:**

1. **Browse Popular MCP Servers**
   - Pre-configured list of most useful MCPs
   - One-click installation
   - Includes: Playwright, Supabase, GitHub, FileSystem, Git, Memory, etc.

2. **Search NPM for MCP Servers**
   - Search by keyword
   - Shows downloads, descriptions
   - Install directly from search

3. **Install from NPM**
   - Manual package installation
   - Auto-configure for tools

4. **Configure MCP Server**
   - Add custom MCPs
   - Set commands or HTTP endpoints

5. **List Installed MCP Servers**
   - View all configured MCPs
   - Per-tool breakdown (Qoder, Kiro, Kilocode)

6. **Remove MCP Server**
   - Clean uninstall
   - Remove from specific tools

7. **Update All MCP Servers**
   - Bulk update via npm-check-updates
   - Keep everything current

8. **Backup MCP Configuration**
   - Save all configs
   - Timestamped backups
   - Easy restore

9. **Show MCP Status**
   - Global packages
   - Available commands
   - Configuration files

**Popular MCPs Available:**
- `playwright` - Browser automation
- `supabase` - Database backend
- `github` - GitHub API integration
- `filesystem` - File operations
- `git` - Git version control
- `memory` - Persistent storage
- `brave-search` - Web search
- `google-maps` - Maps API
- `fetch` - Web content fetching
- `puppeteer` - Browser automation
- `sentry` - Error tracking
- `postgresql` - PostgreSQL database
- `slack` - Slack integration
- `notion` - Notion workspace

---

#### 3. Skills Manager

```bash
./skills-manager.sh
```

**Menu Options:**

1. **Browse Popular Skills**
   - Code Reviewer
   - Debugger
   - Test Generator
   - Documentation Writer
   - Refactoring Assistant
   - Security Auditor
   - Performance Optimizer
   - Git Helper
   - Docker Expert
   - API Design Assistant

2. **Search Available Skills**
   - Search NPM for skills/agents
   - Filter by relevance
   - View download stats

3. **List Installed Skills**
   - Global NPM packages
   - Qoder CLI skills
   - Kiro CLI skills
   - Kilocode skills

4. **Install Skill (NPX)**
   - Try before installing
   - One-time execution
   - No permanent changes

5. **Remove Skill**
   - Uninstall from global packages
   - Clean configuration

6. **Configure Skill**
   - Add to Qoder CLI
   - Add to Kiro CLI
   - Add to both

7. **Update Skills**
   - Update all skill packages
   - Keep current

8. **Backup Skills Configuration**
   - Save all configs
   - Easy migration

9. **Show Skills Status**
   - Installed packages
   - Available commands
   - Configuration files

---

## 🎯 Quick Start Guide

### Step 1: Run Setup

```bash
cd /home/ubuntu/qoder-docker-complete
./setup-complete.sh
```

### Step 2: Enter Container

```bash
./enter.sh
```

### Step 3: Clone Your Repositories

```bash
# This will show you ALL your GitHub repos
# Select multiple with Tab, press Enter to clone
./clone-repos.sh
```

### Step 4: Setup Basic MCPs

```bash
# Quick setup for Playwright + Supabase
./setup-mcp.sh
```

### Step 5: Explore More MCPs

```bash
# Browse marketplace, search, install
./advanced-mcp-manager.sh
```

### Step 6: Add Some Skills

```bash
# Browse and install AI skills
./skills-manager.sh
```

---

## 💡 Usage Examples

### Example 1: Clone Multiple Projects

```bash
# Run the script
./clone-repos.sh

# Interface shows:
# ✓ Select "web", "api", "mobile" with Tab
# ✓ Press Enter
# ✓ All three clone automatically
# ✓ Dependencies install for each
# ✓ Ready to code!
```

### Example 2: Install GitHub MCP

```bash
./advanced-mcp-manager.sh

# Choose: 1. Browse Popular MCP Servers
# Select: github from list
# Choose: 4. All tools
# Done! GitHub MCP now available in Qoder, Kiro, and Kilocode
```

### Example 3: Try a Skill Before Installing

```bash
./skills-manager.sh

# Choose: 1. Browse Popular Skills
# Select: code-reviewer
# Choose: 1. Try with npx
# Test it out!
# If you like it, install globally
```

### Example 4: Search and Install Custom MCP

```bash
./advanced-mcp-manager.sh

# Choose: 2. Search NPM for MCP Servers
# Enter: "database"
# Browse results
# Enter package name to install
# Configure for your tools
```

---

## 🔧 Advanced Configuration

### Custom MCP Server Installation

If you want to add an MCP not in the popular list:

```bash
./advanced-mcp-manager.sh

# Choose: 3. Install from NPM
# Enter: @scope/package-name
# Or choose: 4. Configure MCP Server
# Enter name and command/URL manually
```

### Manual MCP Configuration

For Qoder CLI:
```bash
qodercli mcp add my-mcp "npx -y @scope/package"
```

For Kiro CLI:
```bash
kiro-cli mcp add --name my-mcp --command "npx -y @scope/package"
```

For HTTP-based MCPs:
```bash
qodercli mcp add my-mcp "https://example.com/mcp"
kiro-cli mcp add --name my-mcp --url "https://example.com/mcp"
```

### Skills Configuration Files

**Qoder CLI**: `/root/.qoder.json`
```json
{
  "skills": ["code-reviewer", "debugger"]
}
```

**Kiro CLI**: `/root/.kiro/skills/`
```bash
/root/.kiro/skills/code-reviewer.json
```

---

## 🗂️ File Locations

### Configuration Files

```
/root/
├── .qoder.json              # Qoder CLI config (includes MCPs & skills)
├── .qoder-cli/              # Qoder additional data
├── .kiro/
│   ├── skills/              # Kiro skills configs
│   └── mcp/                 # Kiro MCP configs
└── .kilocode/               # Kilocode configs
```

### Workspace

```
/home/workspace/
├── web/                     # Your cloned repositories
├── api/
├── mobile/
└── backups/                 # Automatic backups
    ├── mcp-YYYYMMDD_HHMMSS/
    └── skills-YYYYMMDD_HHMMSS/
```

### Scripts

```
/scripts/
├── clone-repos.sh           # Dynamic GitHub cloning
├── mcp-manager.sh           # MCP marketplace
└── skills-manager.sh        # Skills manager
```

---

## 🎓 Tips & Tricks

### Pro Tips

1. **Batch Clone Related Projects**
   ```bash
   ./clone-repos.sh
   # Select all projects in same org/family
   # They'll all have deps installed automatically
   ```

2. **Try Before You Commit**
   ```bash
   # Use npx to test skills without installing
   ./skills-manager.sh → Try with npx
   ```

3. **MCP Organization**
   ```bash
   # Group MCPs by purpose:
   # - Dev: playwright, git, filesystem
   # - Prod: supabase, postgresql, sentry
   # - Tools: github, slack, notion
   ```

4. **Regular Backups**
   ```bash
   # Before making big changes
   ./backup.sh
   
   # MCP-specific backup
   ./advanced-mcp-manager.sh → Option 8
   ```

5. **Keep Updated**
   ```bash
   # Update all MCPs monthly
   ./advanced-mcp-manager.sh → Option 7
   
   # Update skills
   ./skills-manager.sh → Option 7
   ```

---

## 🐛 Troubleshooting

### clone-repos.sh Issues

**Problem**: "Not authenticated with GitHub"
```bash
# Authenticate first
gh auth login
```

**Problem**: "No repositories found"
```bash
# Check if you have any repos
gh repo list
```

**Problem**: "Permission denied cloning"
```bash
# For private repos, ensure SSH key is set up
# Or use gh repo clone directly
```

### MCP Manager Issues

**Problem**: "npm search failed"
```bash
# Check internet connection
# Try manual search on npmjs.com
```

**Problem**: "MCP not working after install"
```bash
# Verify installation
npm list -g | grep mcp

# Check tool configuration
qodercli mcp list
kiro-cli mcp list
```

**Problem**: "Command not found"
```bash
# The MCP binary might be in different location
# Try using full path or npx wrapper
```

### Skills Manager Issues

**Problem**: "Skill package not found"
```bash
# Skills might use different naming
# Try: skill-name, @scope/skill-name, @scope/skill-skill-name
```

**Problem**: "Skill doesn't appear in list"
```bash
# Some skills are runtime-only (npx)
# Check if it's installed: npm list -g
```

---

## 📊 Comparison: Before vs After

| Feature | Before | After (v2.0) |
|---------|--------|--------------|
| Repo Cloning | Single, manual | Multi-select, dynamic |
| MCP Installation | Manual config | Marketplace browsing |
| MCP Discovery | None | Search NPM + popular list |
| Skills Management | None | Full manager |
| Backup | Basic | Granular (MCP/Skills separate) |
| Configuration | Manual | Automated + GUI menus |
| Updates | Manual each | Bulk update all |

---

## 🆘 Getting Help

### Built-in Help

Each script has help options:
- Browse interfaces are self-explanatory
- Error messages include suggestions
- Preview panels show details

### Logs

```bash
# Qoder logs
cat /root/.qoder/logs/*.log

# Check installations
npm list -g --depth=0

# Verify MCPs
qodercli mcp list
kiro-cli mcp list
```

### Community Resources

- Qoder Forum: https://forum.qoder.com/
- MCP Protocol: https://modelcontextprotocol.io/
- NPM Search: https://www.npmjs.com/

---

## 🎉 Enjoy Your Enhanced Environment!

You now have:
- ✅ Dynamic GitHub repo management
- ✅ MCP server marketplace
- ✅ Skills/agents manager
- ✅ Automated configurations
- ✅ Backup/restore capabilities
- ✅ Everything encapsulated in Docker

**Happy coding!** 🚀

*Last updated: 2026-03-31*
*Version: 2.0 Enhanced Edition*
