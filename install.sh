#!/usr/bin/env bash

set -euo pipefail

# Find the directory of the script, resolving symlinks
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd)"

# Check if expected directory structure exists
if [ ! -d "$SCRIPT_DIR/lib" ] || [ ! -d "$SCRIPT_DIR/steps" ]; then
    echo "🚀 Bootstrapping server-setup via curl/wget..."
    TMP_DIR=$(mktemp -d)
    
    # NOTE: Replace with your actual repository URL
    REPO_URL="https://github.com/ItsSVK/server_setup.git"
    
    if ! command -v git >/dev/null 2>&1; then
        apt-get update -qq && apt-get install -y -qq git >/dev/null
    fi
    
    git clone -q "$REPO_URL" "$TMP_DIR/server-setup"
    cd "$TMP_DIR/server-setup"
    
    # Execute the cloned script and reconnect stdin for interactive prompts
    exec bash ./install.sh </dev/tty
fi

# Source libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/ui.sh"
source "$SCRIPT_DIR/lib/env.sh"
source "$SCRIPT_DIR/lib/checks.sh"

# Pre-flight checks
check_root
check_os

echo -e "${CYAN}🚀 Starting modular secure server setup...${NC}"

# Start Interactive Prompts
if [ -z "$USERNAME" ]; then
    USERNAME=$(ask "Enter the username to create/configure" "shouvik")
fi

if [ -z "$PUBLIC_KEY" ]; then
    PUBLIC_KEY=$(ask "Enter your SSH Public Key" "")
    while [ -z "$PUBLIC_KEY" ]; do
        warn "SSH Public Key is strictly required for secure authentication."
        PUBLIC_KEY=$(ask "Enter your SSH Public Key" "")
    done
fi

# Export variables so child scripts can access them
export USERNAME
export PUBLIC_KEY

# Show summary of inputs
echo ""
echo -e "${CYAN}===================================${NC}"
echo -e " Summary of Configuration"
echo -e "${CYAN}===================================${NC}"
echo -e " Username:   ${GREEN}$USERNAME${NC}"
echo -e " Public Key: ${GREEN}$PUBLIC_KEY${NC}"
echo -e "${CYAN}===================================${NC}"
echo ""

# Ask for confirmation before running
if ! confirm "Proceed with installation?"; then
    log "Installation aborted by the user."
    exit 0
fi

log "Starting installation steps..."

# Execute all steps in alphabetical/numerical order
for step in "$SCRIPT_DIR"/steps/*.sh; do
    if [ -f "$step" ]; then
        # Running via bash ensures the step executes in its own process
        # Variables exported above will be inherited
        bash "$step"
    fi
done

echo ""
echo -e "${CYAN}===================================${NC}"
log "✅ All steps completed successfully!"
echo -e "${CYAN}👉 Now login using:${NC}"
PUBLIC_IP=$(curl -s ifconfig.me || echo "YOUR_SERVER_IP")
echo -e "${GREEN}ssh $USERNAME@$PUBLIC_IP${NC}"
echo -e "${CYAN}===================================${NC}"

