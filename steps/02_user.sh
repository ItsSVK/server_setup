#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Setting up user: $USERNAME"

if [ -z "$USERNAME" ]; then
    error "USERNAME is not set. Run install.sh or export USERNAME first."
fi

if getent passwd "$USERNAME" > /dev/null; then
    log "User $USERNAME already exists."
else
    log "Creating user $USERNAME..."
    if ! useradd -m -s /bin/bash "$USERNAME"; then
        error "Failed to create user $USERNAME."
    fi
    log "User $USERNAME created."
fi

log "Ensuring $USERNAME is in the sudo group..."
if ! groups "$USERNAME" 2>/dev/null | grep -q "\bsudo\b"; then
    usermod -aG sudo "$USERNAME"
    log "Added $USERNAME to sudo group."
else
    log "User $USERNAME is already in the sudo group."
fi
