#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Updating system packages"

export DEBIAN_FRONTEND=noninteractive

run_with_loader "Updating package lists" apt-get update -qq
run_with_loader "Upgrading installed packages" apt-get upgrade -y -qq
