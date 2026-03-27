#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Configuring UFW firewall"

if ufw status | grep -q "Status: active"; then
    log "UFW is already active."
else
    log "Setting up UFW rules..."
    ufw default deny incoming >/dev/null
    ufw default allow outgoing >/dev/null
    
    ufw allow 22/tcp >/dev/null
    ufw allow 80/tcp >/dev/null
    ufw allow 443/tcp >/dev/null
    
    log "Enabling UFW..."
    ufw --force enable >/dev/null
    log "UFW firewall configured and enabled."
fi
