#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Finalizing setup"

# Lock root account
log "Checking root account status..."
if passwd -S root | grep -q ' L '; then
    log "Root account is already locked."
else
    run_with_loader "Locking root account" passwd -l root
fi

# Passwordless sudo
if [ -n "$USERNAME" ]; then
    SUDOERS_FILE="/etc/sudoers.d/$USERNAME"
    if [ ! -f "$SUDOERS_FILE" ]; then
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
        chmod 440 "$SUDOERS_FILE"
        log "Enabled passwordless sudo for $USERNAME."
    else
        log "Passwordless sudo is already configured for $USERNAME."
    fi
else
    warn "USERNAME is not set. Skipping passwordless sudo configuration."
fi
