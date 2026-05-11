# Qoder CLI v0.1.37 Docker Environment
# Includes: Node.js 24, pnpm, Kiro CLI, Kilocode CLI, Git, Chrome, qodercli

FROM node:24.14.1-slim

LABEL maintainer="Qoder CLI Community"
LABEL version="2.0"
LABEL description="Qoder CLI Docker environment with qodercli, Kiro, Node.js 24"

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
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libatspi2.0-0 \
    ripgrep \
    fd-find \
    jq \
    build-essential \
    dialog \
    fzf \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


Install nvm (Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# Set shell for pnpm
ENV SHELL=/bin/bash

# Load nvm and install Node.js 24
RUN export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install 24 \
    && nvm use 24 \
    && nvm alias default 24

# Enable corepack for pnpm
RUN corepack enable pnpm

# Setup pnpm and add its global bin to PATH
RUN mkdir -p /root/.local/share/pnpm \
    && pnpm setup
ENV PATH="/root/.local/share/pnpm/bin:${PATH}"
ENV PNPM_HOME="/root/.local/share/pnpm"

# Install global packages
RUN pnpm add -g @qoder-ai/qodercli@0.1.37 \
    && pnpm add -g @kilocode/cli \
    && pnpm add -g @playwright/mcp \
    && pnpm add -g npm-check-updates



# Configure Git globally
RUN git config --global user.email "user@example.com" \
    && git config --global user.name "Developer" \
    && git config --global init.defaultBranch master

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

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD command -v qodercli >/dev/null || exit 1

ENTRYPOINT ["qodercli"]
