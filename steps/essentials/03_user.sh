#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Setting up user: $USERNAME"

if [ -z "$USERNAME" ]; then
    error "USERNAME is not set. Run install.sh or export USERNAME first."
fi

if getent passwd "$USERNAME" > /dev/null; then
    log "User $USERNAME already exists."
else
    run_with_loader "Creating user $USERNAME" useradd -m -s /bin/bash "$USERNAME"
fi

if ! groups "$USERNAME" 2>/dev/null | grep -q "\bsudo\b"; then
    run_with_loader "Adding $USERNAME to sudo group" usermod -aG sudo "$USERNAME"
else
    log "User $USERNAME is already in the sudo group."
fi
