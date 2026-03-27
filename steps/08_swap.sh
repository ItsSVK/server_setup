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
    log "Swapfile exists but is not active. Activating it..."
    swapon /swapfile || true
    log "Swapfile activated."
else
    log "Creating 2GB swapfile..."
    # fallocate is faster but may not be supported on all filesystems (e.g., ZFS/Btrfs). Fallback to dd.
    if ! fallocate -l 2G /swapfile 2>/dev/null; then
        warn "fallocate failed, falling back to dd for swap creation..."
        dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
    fi
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    log "Swapfile created and activated."
fi

log "Testing fstab for swap entry..."
if ! grep -q "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    log "Added swapfile to /etc/fstab for persistence."
else
    log "Swapfile already exists in /etc/fstab."
fi
