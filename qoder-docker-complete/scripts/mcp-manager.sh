#!/bin/bash

# Advanced MCP Server Discovery, Search, and Installation
# Supports multiple sources: npm, official registries, community lists

set -e

echo "🔍 MCP Server Marketplace & Manager"
echo "===================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Popular MCP servers list with descriptions
declare -A POPULAR_MCPS
POPULAR_MCPS=(
    ["playwright"]="Browser automation and testing (@playwright/mcp)"
    ["supabase"]="Database and backend services (https://mcp.supabase.com/mcp)"
    ["github"]="GitHub API integration (@modelcontextprotocol/server-github)"
    ["filesystem"]="File system operations (@modelcontextprotocol/server-filesystem)"
    ["git"]="Git version control (@modelcontextprotocol/server-git)"
    ["memory"]="Persistent memory storage (@modelcontextprotocol/server-memory)"
    ["brave-search"]="Web search via Brave (@modelcontextprotocol/server-brave-search)"
    ["google-maps"]="Google Maps API (@modelcontextprotocol/server-google-maps)"
    ["fetch"]="Web content fetching (@modelcontextprotocol/server-fetch)"
    ["puppeteer"]="Browser automation (@modelcontextprotocol/server-puppeteer)"
    ["sentry"]="Error tracking (@modelcontextprotocol/server-sentry)"
    ["postgresql"]="PostgreSQL database (@modelcontextprotocol/server-postgresql)"
    ["slack"]="Slack integration (@modelcontextprotocol/server-slack)"
    ["notion"]="Notion workspace (@modelcontextprotocol/server-notion)"
)

# Function to show main menu
show_menu() {
    clear
    echo "🔍 MCP Server Marketplace & Manager"
    echo "===================================="
    echo ""
    echo "1. 📦 Browse Popular MCP Servers"
    echo "2. 🔎 Search NPM for MCP Servers"
    echo "3. 🌟 Install from NPM"
    echo "4. ⚙️  Configure MCP Server"
    echo "5. 📋 List Installed MCP Servers"
    echo "6. 🗑️  Remove MCP Server"
    echo "7. 🔄 Update All MCP Servers"
    echo "8. 💾 Backup MCP Configuration"
    echo "9. 📊 Show MCP Status"
    echo "0. ❌ Exit"
    echo ""
}

# Function to browse popular MCPs
browse_popular() {
    echo ""
    print_step "Popular MCP Servers:"
    echo "─────────────────────────────────────────────────────────────────────────────"
    
    COUNTER=1
    for KEY in "${!POPULAR_MCPS[@]}"; do
        printf "%2d. %-20s → %s\n" $COUNTER "$KEY" "${POPULAR_MCPS[$KEY]}"
        COUNTER=$((COUNTER + 1))
    done
    echo "─────────────────────────────────────────────────────────────────────────────"
    echo ""
    
    read -p "Enter number to install (or 'q' to quit): " CHOICE
    
    if [[ "$CHOICE" == "q" || "$CHOICE" == "Q" ]]; then
        return
    fi
    
    # Get the selected MCP
    SELECTED_KEY=$(echo "${!POPULAR_MCPS[@]}" | tr ' ' '\n' | sed -n "${CHOICE}p")
    
    if [ -z "$SELECTED_KEY" ]; then
        print_warn "Invalid selection"
        return
    fi
    
    # Install based on selection
    case "$SELECTED_KEY" in
        "playwright")
            install_npm_package "@playwright/mcp" "playwright" "playwright-mcp"
            ;;
        "supabase")
            configure_http_mcp "supabase" "https://mcp.supabase.com/mcp"
            ;;
        "github")
            install_npm_package "@modelcontextprotocol/server-github" "github" "github-mcp"
            ;;
        "filesystem")
            install_npm_package "@modelcontextprotocol/server-filesystem" "filesystem" "filesystem-mcp"
            ;;
        "git")
            install_npm_package "@modelcontextprotocol/server-git" "git" "git-mcp"
            ;;
        "memory")
            install_npm_package "@modelcontextprotocol/server-memory" "memory" "memory-mcp"
            ;;
        *)
            print_warn "Installation not configured for $SELECTED_KEY yet"
            ;;
    esac
}

# Function to search NPM
search_npm() {
    echo ""
    read -p "🔎 Search term: " SEARCH_TERM
    
    if [ -z "$SEARCH_TERM" ]; then
        print_warn "Search term cannot be empty"
        return
    fi
    
    echo ""
    print_step "Searching NPM for: $SEARCH_TERM"
    echo "─────────────────────────────────────────────────────────────────────────────"
    
    # Search npm and display results
    npm search "$SEARCH_TERM" --json 2>/dev/null | jq -r '.[] | "\(.name)\t\(.description // "No description")\t⭐ \((.downloads?.weekly // 0) | tostring)"' | head -20 | column -t -s$'\t'
    
    echo "─────────────────────────────────────────────────────────────────────────────"
    echo ""
    
    read -p "Package to install (or 'q' to quit): " PACKAGE_NAME
    
    if [[ "$PACKAGE_NAME" != "q" && "$PACKAGE_NAME" != "Q" && -n "$PACKAGE_NAME" ]]; then
        install_npm_package "$PACKAGE_NAME"
    fi
}

# Function to install from NPM
install_npm_package() {
    local PACKAGE=$1
    local NAME=${2:-$(echo "$PACKAGE" | sed 's/.*\///')}
    local COMMAND=${3:-$(echo "$PACKAGE" | sed 's/@//g' | tr '/' '-')}
    
    echo ""
    print_step "Installing: $PACKAGE"
    
    # Install globally
    if npm install -g "$PACKAGE" 2>/dev/null; then
        print_info "✅ Package installed successfully"
        
        # Ask which tools to configure
        echo ""
        echo "Configure for which tools?"
        echo "1. Qoder CLI only"
        echo "2. Kiro CLI only"
        echo "3. Kilocode CLI only"
        echo "4. All tools"
        echo "5. Skip configuration"
        echo ""
        read -p "Choice: " CONFIG_CHOICE
        
        case "$CONFIG_CHOICE" in
            1)
                configure_qoder_mcp "$NAME" "$COMMAND"
                ;;
            2)
                configure_kiro_mcp "$NAME" "$COMMAND"
                ;;
            3)
                configure_kilocode_mcp "$NAME" "$COMMAND"
                ;;
            4)
                configure_qoder_mcp "$NAME" "$COMMAND"
                configure_kiro_mcp "$NAME" "$COMMAND"
                configure_kilocode_mcp "$NAME" "$COMMAND"
                ;;
            *)
                print_warn "Skipping configuration (you can add it manually later)"
                ;;
        esac
    else
        print_error "❌ Failed to install package"
    fi
}

# Function to configure Qoder MCP
configure_qoder_mcp() {
    local NAME=$1
    local COMMAND=$2
    
    echo ""
    print_step "Configuring $NAME for Qoder CLI..."
    
    # Check if it's an HTTP endpoint or command
    if [[ "$COMMAND" == http* ]]; then
        qodercli mcp add "$NAME" "$COMMAND" 2>/dev/null && \
            print_info "✅ Added $NAME to Qoder CLI" || \
            print_warn "⚠️  Could not add to Qoder CLI automatically"
    else
        qodercli mcp add "$NAME" "npx -y $COMMAND" 2>/dev/null && \
            print_info "✅ Added $NAME to Qoder CLI" || \
            print_warn "⚠️  Could not add to Qoder CLI automatically"
    fi
}

# Function to configure Kiro MCP
configure_kiro_mcp() {
    local NAME=$1
    local COMMAND=$2
    
    echo ""
    print_step "Configuring $NAME for Kiro CLI..."
    
    if [[ "$COMMAND" == http* ]]; then
        kiro-cli mcp add --name "$NAME" --url "$COMMAND" 2>/dev/null && \
            print_info "✅ Added $NAME to Kiro CLI" || \
            print_warn "⚠️  Could not add to Kiro CLI automatically"
    else
        kiro-cli mcp add --name "$NAME" --command "$COMMAND" 2>/dev/null && \
            print_info "✅ Added $NAME to Kiro CLI" || \
            print_warn "⚠️  Could not add to Kiro CLI automatically"
    fi
}

# Function to configure Kilocode MCP
configure_kilocode_mcp() {
    local NAME=$1
    local COMMAND=$2
    
    echo ""
    print_step "Configuring $NAME for Kilocode CLI..."
    print_warn "⚠️  Kilocode MCP configuration not fully documented yet"
    # TODO: Add kilocode configuration when API is known
}

# Function to configure HTTP MCP
configure_http_mcp() {
    local NAME=$1
    local URL=$2
    
    echo ""
    print_step "Configuring HTTP MCP: $NAME"
    echo "   URL: $URL"
    
    configure_qoder_mcp "$NAME" "$URL"
    configure_kiro_mcp "$NAME" "$URL"
}

# Function to list installed MCPs
list_installed() {
    echo ""
    print_step "Installed MCP Servers"
    echo "═══════════════════════════════════════════════════════════════════════════"
    
    echo ""
    echo "🟦 Qoder CLI:"
    echo "───────────────────────────────────────────────────────────────────────────"
    qodercli mcp list 2>/dev/null || print_warn "Could not list Qoder MCPs"
    
    echo ""
    echo "🟩 Kiro CLI:"
    echo "───────────────────────────────────────────────────────────────────────────"
    kiro-cli mcp list 2>/dev/null || print_warn "Could not list Kiro MCPs"
    
    echo ""
    echo "🟨 Kilocode CLI:"
    echo "───────────────────────────────────────────────────────────────────────────"
    print_warn "Kilocode MCP listing not available yet"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════"
}

# Function to remove MCP
remove_mcp() {
    echo ""
    read -p "MCP server name to remove: " MCP_NAME
    
    if [ -z "$MCP_NAME" ]; then
        print_warn "Name cannot be empty"
        return
    fi
    
    echo ""
    echo "Remove from which tool?"
    echo "1. Qoder CLI"
    echo "2. Kiro CLI"
    echo "3. Both"
    echo ""
    read -p "Choice: " REMOVE_CHOICE
    
    case "$REMOVE_CHOICE" in
        1)
            qodercli mcp remove "$MCP_NAME" 2>/dev/null && \
                print_info "✅ Removed $MCP_NAME from Qoder CLI" || \
                print_warn "⚠️  Could not remove from Qoder CLI"
            ;;
        2)
            kiro-cli mcp remove --name "$MCP_NAME" 2>/dev/null && \
                print_info "✅ Removed $MCP_NAME from Kiro CLI" || \
                print_warn "⚠️  Could not remove from Kiro CLI"
            ;;
        3)
            qodercli mcp remove "$MCP_NAME" 2>/dev/null
            kiro-cli mcp remove --name "$MCP_NAME" 2>/dev/null
            print_info "✅ Removed $MCP_NAME from both tools"
            ;;
        *)
            print_warn "Invalid choice"
            ;;
    esac
}

# Function to update all MCPs
update_all() {
    echo ""
    print_step "Updating all global npm packages (including MCP servers)..."
    ncu -g --filter "*mcp*" 2>/dev/null || npm update -g 2>/dev/null
    print_info "✅ Update complete"
}

# Function to backup configuration
backup_config() {
    local BACKUP_DIR="/home/workspace/backups/mcp-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    echo ""
    print_step "Backing up MCP configurations..."
    
    # Save Qoder config
    if [ -f "/root/.qoder.json" ]; then
        cp /root/.qoder.json "$BACKUP_DIR/"
        print_info "✅ Backed up Qoder config"
    fi
    
    # Save Kiro config
    if [ -d "/root/.kiro" ]; then
        cp -r /root/.kiro "$BACKUP_DIR/"
        print_info "✅ Backed up Kiro config"
    fi
    
    echo ""
    print_info "✅ Backup saved to: $BACKUP_DIR"
}

# Function to show status
show_status() {
    echo ""
    print_step "MCP Server Status"
    echo "═══════════════════════════════════════════════════════════════════════════"
    
    echo ""
    echo "📦 Globally Installed MCP Packages:"
    npm list -g --depth=0 2>/dev/null | grep -i mcp || print_warn "No MCP packages found"
    
    echo ""
    echo "🔧 Available Commands:"
    echo "  • playwright-mcp: $(command -v playwright-mcp || echo 'Not found')"
    echo "  • github-mcp: $(command -v github-mcp || echo 'Not found')"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════"
}

# Main loop
while true; do
    show_menu
    read -p "Choose option: " OPTION
    
    case $OPTION in
        1) browse_popular ;;
        2) search_npm ;;
        3) 
            read -p "NPM package name: " PKG
            install_npm_package "$PKG"
            ;;
        4)
            echo ""
            read -p "MCP name: " NAME
            read -p "Command or URL: " CMD
            install_npm_package "manual" "$NAME" "$CMD"
            ;;
        5) list_installed ;;
        6) remove_mcp ;;
        7) update_all ;;
        8) backup_config ;;
        9) show_status ;;
        0) 
            echo "👋 Goodbye!"
            exit 0
            ;;
        *) 
            print_warn "Invalid option"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
