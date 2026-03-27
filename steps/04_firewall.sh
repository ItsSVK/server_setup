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
    run_with_loader "Setting up default UFW rules" bash -c "ufw default deny incoming && ufw default allow outgoing && ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp"
    
    run_with_loader "Enabling UFW firewall" bash -c "ufw --force enable"
fi
