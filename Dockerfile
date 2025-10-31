# Use default versions for Node.js and Alpine Linux
ARG NODE_VERSION=current
ARG ALPINE_VERSION=latest

# Base images
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS node

# Set version variables
ARG DOCKERIZE_VERSION="v0.9.6"
ARG S6_OVERLAY_VERSION="v3.2.1.0"
ARG S6_OVERLAY_ARCH="x86_64"

# Install dependencies and tools
RUN apk add --no-cache \
    bash \
    curl \
    make \
    gcc \
    g++ \
    nginx \
    ca-certificates \
    coreutils \
    tzdata \
    shadow && \
    apk add --no-cache --virtual=build-dependencies tar && \
    # Add Dockerize
    wget -q https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && \
    rm dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz && \
    # Create necessary directories for Nginx
    mkdir -p /etc/nginx && \
    touch /var/log/nginx/error.log && \
    rm -Rf /etc/nginx/nginx.conf && \
    # Cleanup
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

# Add S6 Overlay
RUN wget -qO- https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -C / -Jx && \
    wget -qO- https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz | tar -C / -Jx && \
    wget -qO- https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz | tar -C / -Jx && \
    wget -qO- https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz | tar -C / -Jx

# Set working directory
WORKDIR /app

# Copy s6-overlay files
ADD rootfs /
