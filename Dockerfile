# Use default versions for Node.js and Alpine Linux
ARG NODE_VERSION=current
ARG ALPINE_VERSION=latest

# Base images
FROM node:${NODE_VERSION}-alpine AS node
FROM alpine:${ALPINE_VERSION}

# Set version variables
ENV DOCKERIZE_VERSION="v0.8.0"
ARG S6_OVERLAY_VERSION="3.2.0.2"
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
    wget -q https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    # Create necessary directories for Nginx
    mkdir -p /etc/nginx && \
    touch /var/log/nginx/error.log && \
    rm -Rf /etc/nginx/nginx.conf && \
    # Cleanup
    apk del --purge build-dependencies && \
    rm -rf /tmp/*

# Add Node.js libraries from the Node image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Add S6 Overlay
RUN wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -C / -Jx && \
    wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz | tar -C / -Jx && \
    wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz | tar -C / -Jx && \
    wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz | tar -C / -Jx

# Set working directory
WORKDIR /app

# Copy additional resources
ADD rootfs /

