#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Configuring Nginx"

if [ "${INSTALL_NGINX:-no}" != "yes" ]; then
    log "Skipping Nginx setup as per user choice."
    exit 0
fi

# We need to install Nginx since we removed it from 01_packages.sh
if command -v nginx >/dev/null 2>&1; then
    log "Nginx is already installed. Skipping installation."
else
    run_with_loader "Installing Nginx" apt-get install -y -qq nginx
fi

if systemctl is-enabled nginx >/dev/null 2>&1; then
    log "Nginx is already enabled to start on boot."
else
    run_with_loader "Enabling Nginx service" systemctl enable nginx
fi

if systemctl is-active nginx >/dev/null 2>&1; then
    log "Nginx is already running."
else
    run_with_loader "Starting Nginx service" systemctl start nginx
fi
