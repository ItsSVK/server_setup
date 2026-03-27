#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Updating system packages"

export DEBIAN_FRONTEND=noninteractive

log "Running apt update and upgrade..."
if ! apt-get update -qq; then
    error "Failed to update package lists."
fi

if ! apt-get upgrade -y -qq; then
    error "Failed to upgrade packages."
fi

log "System packages updated successfully."
