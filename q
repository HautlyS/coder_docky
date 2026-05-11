#!/bin/bash

# Qoder CLI Docker Runner
IMAGE="qodercli-bug"
WORKDIR="$(pwd)"

# Persist config directories
CONFIG_DIR="$HOME/.qoder"
CONFIG_CLI_DIR="$HOME/.qoder-cli"

# Create config dirs if they don't exist
mkdir -p "$CONFIG_DIR" "$CONFIG_CLI_DIR"

# Check if any argument requires TTY (TUI modes)
NEEDS_TTY=false
for arg in "$@"; do
    case "$arg" in
        --yolo|-y|--tui|--interactive|-i)
            NEEDS_TTY=true
            ;;
    esac
done

if [ $# -eq 0 ]; then
    # Interactive - needs TTY
    if [ -t 0 ]; then
        exec docker run --rm -it \
            -v "$CONFIG_DIR:/root/.qoder" \
            -v "$CONFIG_CLI_DIR:/root/.qoder-cli" \
            -v "$WORKDIR:/home/workspace" \
            -w /home/workspace \
            "$IMAGE"
    else
        echo "Error: Interactive mode requires a TTY"
        echo "Usage: q 'your prompt'  (for non-interactive use)"
        exit 1
    fi
elif [ "$NEEDS_TTY" = true ]; then
    # TUI mode - needs TTY
    if [ -t 0 ]; then
        exec docker run --rm -it \
            -v "$CONFIG_DIR:/root/.qoder" \
            -v "$CONFIG_CLI_DIR:/root/.qoder-cli" \
            -v "$WORKDIR:/home/workspace" \
            -w /home/workspace \
            "$IMAGE" "$@"
    else
        echo "Error: TUI mode ($*) requires a TTY"
        echo "Run with: docker run -it ... or use q 'your prompt' for non-interactive"
        exit 1
    fi
else
    # Pass args directly - non-interactive, no TTY needed
    exec docker run --rm \
        -v "$CONFIG_DIR:/root/.qoder" \
        -v "$CONFIG_CLI_DIR:/root/.qoder-cli" \
        -v "$WORKDIR:/home/workspace" \
        -w /home/workspace \
        "$IMAGE" "$@"
fi