# Qoder CLI v0.1.37 - Encapsulated Environment
# This Docker image preserves Qoder CLI version 0.1.37 with all configurations
# Auto-updates are disabled to maintain version stability

FROM node:24.14.1-slim

LABEL maintainer="Qoder CLI User"
LABEL version="0.1.37"
LABEL description="Encapsulated Qoder CLI v0.1.37 with disabled auto-updates"

# Prevent any automatic updates at system level
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production

# Install essential tools and dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    ca-certificates \
    gnupg \
    openssh-client \
    ripgrep \
    fd-find \
    jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create qoder user for security (optional, can run as root)
RUN useradd -m -s /bin/bash qoder || true

# Set up working directory
WORKDIR /home/qoder

# Copy Qoder CLI npm package files (to be added during build)
COPY ./qodercli-package/ /tmp/qodercli-package/

# Install the specific version of Qoder CLI globally
RUN npm install -g /tmp/qodercli-package --legacy-peer-deps \
    && npm cache clean --force

# Disable npm auto-update checks
RUN echo 'disable-renewal-updates=true' >> /usr/local/etc/npmrc \
    && echo 'update-notifier=false' >> /usr/local/etc/npmrc

# Create Qoder configuration directories
RUN mkdir -p /home/qoder/.qoder \
    && mkdir -p /home/qoder/.qoder-cli \
    && chown -R qoder:qoder /home/qoder/.qoder \
    && chown -R qoder:qoder /home/qoder/.qoder-cli

# Copy Qoder configuration files (to be added during build)
COPY ./qoder-config/.qoder.json /home/qoder/.qoder.json
COPY ./qoder-config/.config.json /home/qoder/.qoder/.config.json

# Set ownership
RUN chown qoder:qoder /home/qoder/.qoder.json \
    && chown qoder:qoder /home/qoder/.qoder/.config.json

# Switch to qoder user
USER qoder

# Set environment variables for Qoder
ENV HOME=/home/qoder
ENV PATH=$PATH:/home/qoder/.nvm/versions/node/v24.14.1/bin

# Configure Git (optional)
RUN git config --global user.name "Qoder User" \
    && git config --global user.email "user@qoder.local"

# Expose any needed ports (for MCP servers, etc.)
EXPOSE 3000 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD command -v qodercli >/dev/null || exit 1

# Default command
CMD ["/bin/bash"]
