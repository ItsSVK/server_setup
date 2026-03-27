#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Configuring Swap space"

if grep -q "/swapfile" /proc/swaps; then
    log "Swap space is already active."
elif [ -f /swapfile ]; then
    run_with_loader "Activating existing swapfile" swapon /swapfile
else
    log "Creating 2GB swapfile..."
    if ! fallocate -l 2G /swapfile 2>/dev/null; then
        warn "fallocate failed, falling back to dd for swap creation..."
        run_with_loader "Creating 2GB swapfile (dd)" dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
    else
        log "fallocate succeeded."
    fi
    chmod 600 /swapfile
    run_with_loader "Setting up swapspace" mkswap /swapfile
    run_with_loader "Activating swapfile" swapon /swapfile
fi

log "Testing fstab for swap entry..."
if ! grep -q "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log "Added swapfile to /etc/fstab for persistence."
else
    log "Swapfile already exists in /etc/fstab."
fi
