#!/bin/bash

# Qoder CLI Docker Runner
IMAGE="qodercli-bug"
WORKDIR="$(pwd)"

# Persist config directories
CONFIG_DIR="$HOME/.qoder"
CONFIG_CLI_DIR="$HOME/.qoder-cli"

# Create config dirs if they don't exist
mkdir -p "$CONFIG_DIR" "$CONFIG_CLI_DIR"

if [ $# -eq 0 ]; then
    # Interactive - needs TTY
    exec docker run --rm -it \
        -v "$CONFIG_DIR:/root/.qoder" \
        -v "$CONFIG_CLI_DIR:/root/.qoder-cli" \
        -v "$WORKDIR:/home/workspace" \
        -w /home/workspace \
        "$IMAGE"
else
    # Pass args directly
    exec docker run --rm \
        -v "$CONFIG_DIR:/root/.qoder" \
        -v "$CONFIG_CLI_DIR:/root/.qoder-cli" \
        -v "$WORKDIR:/home/workspace" \
        -w /home/workspace \
        "$IMAGE" "$@"
fi