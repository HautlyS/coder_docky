# Complete Development Environment with Dynamic GitHub, MCP, and Skills Support
# Enhanced with repo discovery, MCP marketplace, and skills management

FROM node:24.14.1-slim

LABEL maintainer="Psiu Project"
LABEL version="2.0"
LABEL description="Enhanced dev environment: Dynamic GitHub repos, MCP marketplace, Skills manager"

# Prevent interactive prompts and set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV NVM_DIR=/root/.nvm
ENV PATH=/root/.nvm/versions/node/v24/bin:$PATH

# Install all system dependencies at once
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    gnupg \
    openssh-client \
    unzip \
    gh \
    libasound2t64 \
    ripgrep \
    fd-find \
    jq \
    build-essential \
    dialog \
    fzf \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Download and install Google Chrome
RUN wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i /tmp/chrome.deb || apt-get -f install -y \
    && rm /tmp/chrome.deb

# Install nvm (Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# Load nvm and install Node.js 24
RUN export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 24 \
    && nvm use 24 \
    && nvm alias default 24

# Enable corepack for pnpm
RUN corepack enable pnpm

# Setup pnpm
RUN pnpm setup

# Install global packages
RUN npm install -g @qoder-ai/qodercli@0.1.37 \
    && npm install -g @kilocode/cli \
    && npm install -g @playwright/mcp \
    && npm install -g npm-check-updates

# Install Kiro CLI
RUN curl -fsSL https://cli.kiro.dev/install | bash

# Add kiro to PATH
ENV PATH="/root/.local/bin:$PATH"

# Configure Git globally
RUN git config --global user.email "psiu.proj@icloud.com" \
    && git config --global user.name "Psiu" \
    && git config --global init.defaultBranch main

# Create working directory
WORKDIR /home/workspace

# Disable auto-updates for Qoder CLI
RUN echo '{"autoUpdates": false, "autoCompactEnabled": true, "todoFeatureEnabled": true, "checkpointingEnabled": true, "verbose": false, "theme": "Qoder", "autoConnectIde": false, "maxOutputTokens": 16384, "modelLevel": "ultimate"}' > /root/.qoder.json

# Disable npm update notifications
RUN echo 'disable-renewal-updates=true' >> /usr/local/etc/npmrc \
    && echo 'update-notifier=false' >> /usr/local/etc/npmrc

# Create directories
RUN mkdir -p /root/.qoder \
    && mkdir -p /root/.qoder-cli \
    && mkdir -p /root/.kiro \
    && mkdir -p /root/.kilocode \
    && mkdir -p /workspace \
    && mkdir -p /scripts

# Set permissions
RUN chmod -R 755 /root/.qoder \
    && chmod -R 755 /root/.qoder-cli \
    && chmod -R 755 /root/.kiro \
    && chmod -R 755 /root/.kilocode

# Copy enhanced scripts
COPY ./scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Health checks
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD command -v qodercli >/dev/null && command -v kiro-cli >/dev/null || exit 1

# Default command
CMD ["/bin/bash"]
