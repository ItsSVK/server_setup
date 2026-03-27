#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Installing essential packages"

export DEBIAN_FRONTEND=noninteractive

PACKAGES="curl wget git ufw fail2ban"

run_with_loader "Installing common packages" apt-get install -y -qq $PACKAGES
