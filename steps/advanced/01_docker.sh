#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Installing and configuring Docker"

if [ "${INSTALL_DOCKER:-no}" != "yes" ]; then
    log "Skipping Docker setup as per user choice."
    exit 0
fi

export DEBIAN_FRONTEND=noninteractive

if command -v docker >/dev/null 2>&1; then
    log "Docker is already installed."
else
    run_with_loader "Removing obsolete Docker packages" apt-get remove -y -qq docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc
    
    log "Adding Docker's official GPG key..."
    install -m 0755 -d /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        run_with_loader "Downloading Docker GPG key" curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
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

    # Update cache first
    run_with_loader "Updating apt cache for Docker" apt-get update -qq

    # Install docker packages
    run_with_loader "Installing Docker CE packages" apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

if ! systemctl is-enabled docker >/dev/null 2>&1; then
    run_with_loader "Enabling Docker service" systemctl enable docker
fi

if ! systemctl is-active docker >/dev/null 2>&1; then
    run_with_loader "Starting Docker service" systemctl start docker
fi

if [ -n "$USERNAME" ]; then
    if ! groups "$USERNAME" 2>/dev/null | grep -q "\bdocker\b"; then
        run_with_loader "Adding $USERNAME to docker group" usermod -aG docker "$USERNAME"
    else
        log "User $USERNAME is already in the docker group."
    fi
else
    warn "USERNAME is not set. Skipping adding user to docker group."
fi
