#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Configuring Nginx"

if systemctl is-enabled nginx >/dev/null 2>&1; then
    log "Nginx is already enabled to start on boot."
else
    log "Enabling Nginx service..."
    systemctl enable nginx >/dev/null 2>&1
fi

if systemctl is-active nginx >/dev/null 2>&1; then
    log "Nginx is already running."
else
    log "Starting Nginx service..."
    systemctl start nginx >/dev/null 2>&1
    log "Nginx started successfully."
fi
