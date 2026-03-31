#!/bin/bash

# Skills Manager for Qoder CLI, Kiro CLI, and Kilocode CLI
# Search, install, list, and manage AI skills/agents

set -e

echo "🧠 Skills Manager - AI Agents & Subagents"
echo "=========================================="
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

# Popular skills directory
declare -A POPULAR_SKILLS
POPULAR_SKILLS=(
    ["code-reviewer"]="Review code changes and suggest improvements"
    ["debugger"]="Help debug and fix issues in your code"
    ["test-generator"]="Generate unit tests for your code"
    ["documentation"]="Write documentation and docstrings"
    ["refactor"]="Suggest code refactoring improvements"
    ["security-audit"]="Check for security vulnerabilities"
    ["performance"]="Optimize code performance"
    ["git-helper"]="Assist with Git operations"
    ["docker-expert"]="Help with Docker and containerization"
    ["api-design"]="Assist with API design and best practices"
)

# Function to show main menu
show_menu() {
    clear
    echo "🧠 Skills Manager - AI Agents & Subagents"
    echo "=========================================="
    echo ""
    echo "1. 📦 Browse Popular Skills"
    echo "2. 🔎 Search Available Skills"
    echo "3. 📋 List Installed Skills"
    echo "4. ➕ Install Skill (NPX)"
    echo "5. 🗑️  Remove Skill"
    echo "6. ⚙️  Configure Skill"
    echo "7. 🔄 Update Skills"
    echo "8. 💾 Backup Skills Configuration"
    echo "9. 📊 Show Skills Status"
    echo "0. ❌ Exit"
    echo ""
}

# Function to browse popular skills
browse_popular() {
    echo ""
    print_step "Popular Skills / Agents:"
    echo "─────────────────────────────────────────────────────────────────────────────"
    
    COUNTER=1
    for KEY in "${!POPULAR_SKILLS[@]}"; do
        printf "%2d. %-25s → %s\n" $COUNTER "$KEY" "${POPULAR_SKILLS[$KEY]}"
        COUNTER=$((COUNTER + 1))
    done
    echo "─────────────────────────────────────────────────────────────────────────────"
    echo ""
    
    read -p "Enter skill number to explore (or 'q' to quit): " CHOICE
    
    if [[ "$CHOICE" == "q" || "$CHOICE" == "Q" ]]; then
        return
    fi
    
    # Get the selected skill
    SELECTED_KEY=$(echo "${!POPULAR_SKILLS[@]}" | tr ' ' '\n' | sed -n "${CHOICE}p")
    
    if [ -z "$SELECTED_KEY" ]; then
        print_warn "Invalid selection"
        return
    fi
    
    echo ""
    print_info "Skill: $SELECTED_KEY"
    echo "Description: ${POPULAR_SKILLS[$SELECTED_KEY]}"
    echo ""
    echo "Actions:"
    echo "1. Try with npx (one-time use)"
    echo "2. Install globally"
    echo "3. Go back"
    echo ""
    read -p "Choice: " ACTION_CHOICE
    
    case "$ACTION_CHOICE" in
        1)
            try_with_npx "$SELECTED_KEY"
            ;;
        2)
            install_skill_globally "$SELECTED_KEY"
            ;;
        3)
            return
            ;;
        *)
            print_warn "Invalid choice"
            ;;
    esac
}

# Function to search skills
search_skills() {
    echo ""
    read -p "🔎 Search term (e.g., 'agent', 'skill', 'assistant'): " SEARCH_TERM
    
    if [ -z "$SEARCH_TERM" ]; then
        print_warn "Search term cannot be empty"
        return
    fi
    
    echo ""
    print_step "Searching NPM for skills related to: $SEARCH_TERM"
    echo "─────────────────────────────────────────────────────────────────────────────"
    
    # Search npm
    npm search "$SEARCH_TERM" --json 2>/dev/null | jq -r '.[] | select(.name | test("skill|agent|assistant"; "i")) | "\(.name)\t\(.description // "No description")\t⭐ \((.downloads?.weekly // 0) | tostring)"' | head -20 | column -t -s$'\t'
    
    echo "─────────────────────────────────────────────────────────────────────────────"
    echo ""
    
    read -p "Skill to try with npx (or 'q' to quit): " SKILL_NAME
    
    if [[ "$SKILL_NAME" != "q" && "$SKILL_NAME" != "Q" && -n "$SKILL_NAME" ]]; then
        try_with_npx "$SKILL_NAME"
    fi
}

# Function to try skill with npx
try_with_npx() {
    local SKILL=$1
    
    echo ""
    print_step "Trying $SKILL with npx (one-time execution)..."
    echo ""
    echo "This will run the skill without installing it permanently."
    echo "Perfect for testing before installing!"
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."
    
    # Run with npx
    if command -v qodercli &>/dev/null; then
        echo ""
        print_info "Running with Qoder CLI..."
        qodercli "/skills use $SKILL" 2>&1 || print_warn "Skill execution completed with warnings"
    else
        print_warn "Qoder CLI not found, trying direct npx..."
        npx -y "$SKILL" 2>&1 || print_warn "Skill execution completed"
    fi
}

# Function to install skill globally
install_skill_globally() {
    local SKILL=$1
    
    echo ""
    print_step "Installing $SKILL globally..."
    
    # Try different package name patterns
    local PACKAGES=(
        "@qoder-ai/skill-$SKILL"
        "skill-$SKILL"
        "@kiro-ai/skill-$SKILL"
        "$SKILL"
    )
    
    local INSTALLED=false
    
    for PKG in "${PACKAGES[@]}"; do
        echo "Trying package: $PKG"
        if npm install -g "$PKG" 2>/dev/null; then
            print_info "✅ Successfully installed $PKG"
            INSTALLED=true
            break
        fi
    done
    
    if [ "$INSTALLED" = false ]; then
        print_warn "⚠️  Could not find/install skill package"
        echo "You may need to search for the correct package name on npmjs.com"
    fi
}

# Function to list installed skills
list_installed() {
    echo ""
    print_step "Installed Skills & Agents"
    echo "═══════════════════════════════════════════════════════════════════════════"
    
    echo ""
    echo "📦 Global NPM Packages (Skills):"
    npm list -g --depth=0 2>/dev/null | grep -E "(skill|agent|assistant)" || print_warn "No skill packages found"
    
    echo ""
    echo "🟦 Qoder CLI Skills:"
    echo "───────────────────────────────────────────────────────────────────────────"
    if [ -f "/root/.qoder.json" ]; then
        jq -r '.skills // empty' /root/.qoder.json 2>/dev/null || print_warn "No skills configured"
    else
        print_warn "Qoder config not found"
    fi
    
    echo ""
    echo "🟩 Kiro CLI Skills:"
    echo "───────────────────────────────────────────────────────────────────────────"
    if [ -d "/root/.kiro" ]; then
        find /root/.kiro -name "*skill*" -o -name "*agent*" 2>/dev/null | head -10 || print_warn "No skills found"
    else
        print_warn "Kiro config not found"
    fi
    
    echo ""
    echo "🟨 Kilocode CLI Skills:"
    echo "───────────────────────────────────────────────────────────────────────────"
    print_warn "Kilocode skills listing not available yet"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════"
}

# Function to remove skill
remove_skill() {
    echo ""
    read -p "Skill package name to remove: " SKILL_NAME
    
    if [ -z "$SKILL_NAME" ]; then
        print_warn "Name cannot be empty"
        return
    fi
    
    echo ""
    print_step "Removing $SKILL_NAME..."
    
    if npm uninstall -g "$SKILL_NAME" 2>/dev/null; then
        print_info "✅ Removed $SKILL_NAME from global packages"
    else
        print_warn "⚠️  Could not remove package (may not be installed)"
    fi
}

# Function to configure skill
configure_skill() {
    echo ""
    read -p "Skill/Agent name: " SKILL_NAME
    
    if [ -z "$SKILL_NAME" ]; then
        print_warn "Name cannot be empty"
        return
    fi
    
    echo ""
    echo "Configure for which tool?"
    echo "1. Qoder CLI"
    echo "2. Kiro CLI"
    echo "3. Both"
    echo ""
    read -p "Choice: " CONFIG_CHOICE
    
    case "$CONFIG_CHOICE" in
        1)
            echo ""
            print_step "Configuring $SKILL_NAME for Qoder CLI..."
            # Add to Qoder skills configuration
            if [ -f "/root/.qoder.json" ]; then
                # Use jq to safely modify JSON
                if command -v jq &>/dev/null; then
                    jq ".skills += [\"$SKILL_NAME\"]" /root/.qoder.json > /tmp/qoder_temp.json && \
                        mv /tmp/qoder_temp.json /root/.qoder.json
                    print_info "✅ Added $SKILL_NAME to Qoder skills"
                else
                    print_warn "jq not found, manual configuration required"
                fi
            fi
            ;;
        2)
            echo ""
            print_step "Configuring $SKILL_NAME for Kiro CLI..."
            # Create skill config file
            mkdir -p /root/.kiro/skills
            echo "{\"name\": \"$SKILL_NAME\", \"enabled\": true}" > "/root/.kiro/skills/$SKILL_NAME.json"
            print_info "✅ Added $SKILL_NAME to Kiro skills"
            ;;
        3)
            # Configure for both
            if [ -f "/root/.qoder.json" ] && command -v jq &>/dev/null; then
                jq ".skills += [\"$SKILL_NAME\"]" /root/.qoder.json > /tmp/qoder_temp.json && \
                    mv /tmp/qoder_temp.json /root/.qoder.json
                print_info "✅ Added $SKILL_NAME to Qoder skills"
            fi
            
            mkdir -p /root/.kiro/skills
            echo "{\"name\": \"$SKILL_NAME\", \"enabled\": true}" > "/root/.kiro/skills/$SKILL_NAME.json"
            print_info "✅ Added $SKILL_NAME to Kiro skills"
            ;;
        *)
            print_warn "Invalid choice"
            ;;
    esac
}

# Function to update skills
update_skills() {
    echo ""
    print_step "Updating all skill-related packages..."
    
    # Update global packages
    npm update -g 2>/dev/null || print_warn "Some packages could not be updated"
    
    echo ""
    print_info "✅ Update complete"
}

# Function to backup skills configuration
backup_skills() {
    local BACKUP_DIR="/home/workspace/backups/skills-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    echo ""
    print_step "Backing up skills configurations..."
    
    # Backup Qoder config
    if [ -f "/root/.qoder.json" ]; then
        cp /root/.qoder.json "$BACKUP_DIR/qoder-config.json"
        print_info "✅ Backed up Qoder config"
    fi
    
    # Backup Kiro skills
    if [ -d "/root/.kiro/skills" ]; then
        cp -r /root/.kiro/skills "$BACKUP_DIR/kiro-skills/"
        print_info "✅ Backed up Kiro skills"
    fi
    
    # Backup Kilocode config if exists
    if [ -d "/root/.kilocode" ]; then
        cp -r /root/.kilocode "$BACKUP_DIR/kilocode/"
        print_info "✅ Backed up Kilocode config"
    fi
    
    echo ""
    print_info "✅ Backup saved to: $BACKUP_DIR"
}

# Function to show status
show_status() {
    echo ""
    print_step "Skills & Agents Status"
    echo "═══════════════════════════════════════════════════════════════════════════"
    
    echo ""
    echo "📦 Installed Skill Packages:"
    npm list -g --depth=0 2>/dev/null | grep -iE "(skill|agent|assistant)" || print_warn "None found"
    
    echo ""
    echo "🔧 Available Commands:"
    echo "  • qodercli /skills: $(command -v qodercli >/dev/null && echo 'Available' || echo 'Not installed')"
    echo "  • kiro-cli skills: $(command -v kiro-cli >/dev/null && echo 'Available' || echo 'Not installed')"
    echo "  • kilocode: $(command -v kilocode >/dev/null && echo 'Available' || echo 'Not installed')"
    
    echo ""
    echo "📁 Configuration Files:"
    echo "  • Qoder: /root/.qoder.json $([ -f /root/.qoder.json ] && echo '✅' || echo '❌')"
    echo "  • Kiro: /root/.kiro/skills/ $([ -d /root/.kiro/skills ] && echo '✅' || echo '❌')"
    echo "  • Kilocode: /root/.kilocode/ $([ -d /root/.kilocode ] && echo '✅' || echo '❌')"
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════════"
}

# Main loop
while true; do
    show_menu
    read -p "Choose option: " OPTION
    
    case $OPTION in
        1) browse_popular ;;
        2) search_skills ;;
        3) list_installed ;;
        4)
            read -p "Skill/package name: " SKILL
            try_with_npx "$SKILL"
            ;;
        5) remove_skill ;;
        6) configure_skill ;;
        7) update_skills ;;
        8) backup_skills ;;
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
