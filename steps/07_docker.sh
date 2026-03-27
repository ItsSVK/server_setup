#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Installing and configuring Docker"

export DEBIAN_FRONTEND=noninteractive

if command -v docker >/dev/null 2>&1; then
    log "Docker is already installed."
else
    log "Removing obsolete Docker packages..."
    apt-get remove -y -qq docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc 2>/dev/null || true

    log "Adding Docker's official GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
    fi

    log "Adding Docker repository to Apt sources..."
    if [ ! -f /etc/apt/sources.list.d/docker.sources ]; then
        tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    fi

    log "Installing Docker CE..."
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    log "Docker installed successfully."
fi

if ! systemctl is-enabled docker >/dev/null 2>&1; then
    log "Enabling Docker service..."
    systemctl enable docker >/dev/null 2>&1
fi

if ! systemctl is-active docker >/dev/null 2>&1; then
    log "Starting Docker service..."
    systemctl start docker >/dev/null 2>&1
fi

if [ -n "$USERNAME" ]; then
    log "Ensuring $USERNAME is in the docker group..."
    if ! groups "$USERNAME" 2>/dev/null | grep -q "\bdocker\b"; then
        usermod -aG docker "$USERNAME"
        log "Added $USERNAME to docker group."
    else
        log "User $USERNAME is already in the docker group."
    fi
else
    warn "USERNAME is not set. Skipping adding user to docker group."
fi
