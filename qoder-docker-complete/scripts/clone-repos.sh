#!/bin/bash

# Dynamic GitHub Repository Cloning with Multi-Select
# Loads all repos from authenticated GitHub account and lets user choose

set -e

echo "🔍 Loading your GitHub repositories..."
echo ""

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "Please run: gh auth login"
    exit 1
fi

# Get username
USERNAME=$(gh api user --jq .login)
echo "✅ Logged in as: $USERNAME"
echo ""

# Fetch all repositories (public and private)
echo "📦 Fetching repositories..."
REPOS=$(gh repo list --limit 1000 --json name,description,isPrivate,updatedAt,stargazerCount | jq -r '.[] | "\(.name)\t\(.description // "No description")\t\(.isPrivate)\t\(.updatedAt)\t\(.stargazerCount)"')

if [ -z "$REPOS" ]; then
    echo "❌ No repositories found"
    exit 1
fi

# Create temporary file for selection
TEMP_FILE=$(mktemp)
echo "$REPOS" > "$TEMP_FILE"

# Display repositories with checkboxes using fzf
echo ""
echo "📋 Select repositories to clone (use Tab to select multiple, Enter to confirm):"
echo "─────────────────────────────────────────────────────────────────────────────"
echo ""

# Format for fzf with preview
SELECTED_REPOS=$(cat "$TEMP_FILE" | \
    awk -F'\t' '{printf "%s\t%s (%s ⭐)\n", $1, $2, $5}' | \
    fzf --multi \
        --preview 'echo {} | cut -f1 | xargs -I {} gh repo view {} --json description,createdAt,pushedAt,url | jq -r "\"\(.description)\n\nCreated: \(.createdAt)\nLast Push: \(.pushedAt)\nURL: \(.url)\""\' \
        --preview-window=wrap \
        --header='Select repos (Tab/Ctrl-Space to toggle, Enter to confirm)' \
        --bind='ctrl-a:select-all,ctrl-d:deselect-all' \
        --layout=reverse \
        --border \
        --height=80%)

rm "$TEMP_FILE"

if [ -z "$SELECTED_REPOS" ]; then
    echo "⚠️  No repositories selected"
    exit 0
fi

# Extract repo names
REPO_NAMES=$(echo "$SELECTED_REPOS" | cut -f1)

# Count total selected
TOTAL=$(echo "$REPO_NAMES" | wc -l)
echo ""
echo "📥 Cloning $TOTAL repository(ies)..."
echo "─────────────────────────────────────────────────────────────────────────────"
echo ""

# Clone each selected repository
COUNTER=0
SUCCESS=0
FAILED=0

while IFS= read -r REPO_NAME; do
    COUNTER=$((COUNTER + 1))
    
    # Check if already exists
    if [ -d "/home/workspace/$REPO_NAME" ]; then
        echo "[$COUNTER/$TOTAL] ⚠️  $REPO_NAME already exists, skipping..."
        continue
    fi
    
    # Clone repository
    echo "[$COUNTER/$TOTAL] 🔄 Cloning $REPO_NAME..."
    cd /home/workspace
    
    if gh repo clone "$USERNAME/$REPO_NAME" -- --depth 1; then
        echo "         ✅ Successfully cloned $REPO_NAME"
        SUCCESS=$((SUCCESS + 1))
        
        # Install dependencies if package.json exists
        cd "$REPO_NAME"
        if [ -f "package.json" ]; then
            echo "         📦 Installing dependencies..."
            if [ -f "pnpm-lock.yaml" ]; then
                pnpm install --frozen-lockfile
            elif [ -f "yarn.lock" ]; then
                yarn install --frozen-lockfile
            else
                npm ci
            fi
            echo "         ✅ Dependencies installed"
        fi
        cd /home/workspace
    else
        echo "         ❌ Failed to clone $REPO_NAME"
        FAILED=$((FAILED + 1))
    fi
    echo ""
done <<< "$REPO_NAMES"

# Summary
echo "─────────────────────────────────────────────────────────────────────────────"
echo "✅ Cloning complete!"
echo "   Successful: $SUCCESS"
echo "   Failed: $FAILED"
echo "   Skipped (already exists): $((TOTAL - SUCCESS - FAILED))"
echo ""
echo "📁 Your repositories are in: /home/workspace/"
echo "─────────────────────────────────────────────────────────────────────────────"
