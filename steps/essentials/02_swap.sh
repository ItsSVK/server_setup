#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

# Calculate optimal swap size based on total RAM
TOTAL_MEM_MB=$(free -m | awk '/^Mem:/{print $2}')
if [ -z "$TOTAL_MEM_MB" ]; then
    SWAP_SIZE_MB=2048
    SWAP_SIZE_G=2
elif [ "$TOTAL_MEM_MB" -lt 2000 ]; then
    SWAP_SIZE_MB=$((TOTAL_MEM_MB * 2))
    SWAP_SIZE_G=$((SWAP_SIZE_MB / 1024))
elif [ "$TOTAL_MEM_MB" -lt 8000 ]; then
    SWAP_SIZE_MB=$TOTAL_MEM_MB
    SWAP_SIZE_G=$((SWAP_SIZE_MB / 1024))
else
    SWAP_SIZE_MB=4096
    SWAP_SIZE_G=4
fi

[ "$SWAP_SIZE_G" -eq 0 ] && SWAP_SIZE_G=1

step_info "Configuring dynamically sized Swap space (${SWAP_SIZE_MB}MB)"

if grep -q "/swapfile" /proc/swaps; then
    log "Swap space is already active."
elif [ -f /swapfile ]; then
    run_with_loader "Activating existing swapfile" swapon /swapfile
else
    log "Creating ${SWAP_SIZE_G}GB swapfile..."
    if ! fallocate -l ${SWAP_SIZE_G}G /swapfile 2>/dev/null; then
        warn "fallocate failed, falling back to dd for swap creation..."
        run_with_loader "Creating ${SWAP_SIZE_MB}MB swapfile (dd)" dd if=/dev/zero of=/swapfile bs=1M count=$SWAP_SIZE_MB status=none
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
