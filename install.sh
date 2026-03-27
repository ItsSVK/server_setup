#!/usr/bin/env bash

set -euo pipefail

# Find the directory of the script, resolving symlinks
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd)"

# Parse arguments
ADVANCED_MODE="no"
for arg in "$@"; do
    if [ "$arg" == "-f" ] || [ "$arg" == "--full" ]; then
        ADVANCED_MODE="yes"
    fi
done

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
echo -e "\n${CYAN}====================================================${NC}"
echo -e "${GREEN}Welcome to the Server Setup Wizard!${NC}"
echo -e "This script will:"
echo -e " - Create a new account with your chosen username"
echo -e " - Enable SSH login (Key required) & disable Password auth"
echo -e " - Setup basic security (ufw, fail2ban) & essential tools"
echo -e "${CYAN}====================================================${NC}\n"

if [ -z "${USERNAME:-}" ]; then
    USERNAME=$(ask "Enter the username to create/configure" "ubuntu")
fi

if [ -z "${PUBLIC_KEY:-}" ]; then
    PUBLIC_KEY=$(ask "Enter your SSH Public Key" "")
    while [ -z "$PUBLIC_KEY" ]; do
        warn "SSH Public Key is strictly required for secure authentication."
        PUBLIC_KEY=$(ask "Enter your SSH Public Key" "")
    done
fi

export USERNAME
export PUBLIC_KEY

if ! confirm "Proceed with the core setup?"; then
    log "Setup aborted by the user."
    exit 0
fi

INSTALL_NGINX="no"
INSTALL_DOCKER="no"
INSTALL_NVM="no"

if [ "$ADVANCED_MODE" != "yes" ]; then
    echo -e "\n${CYAN}Running in Essential Mode.${NC}"
    if confirm "Would you like to switch to Advanced Mode to install optional tools (Nginx, Docker etc)?"; then
        ADVANCED_MODE="yes"
    fi
fi

if [ "$ADVANCED_MODE" == "yes" ]; then
    echo -e "\n${CYAN}===================================${NC}"
    echo -e "${YELLOW}Advanced Mode Enabled${NC}"
    echo -e "${CYAN}===================================${NC}"
    
    if confirm "Install Docker? (Containers Engine)"; then
        INSTALL_DOCKER="yes"
    fi

    if confirm "Install Nginx? (Web Server)"; then
        INSTALL_NGINX="yes"
    fi

    if confirm "Install NVM? (Node Version Manager)"; then
        INSTALL_NVM="yes"
    fi
else
    echo -e "Skipping advanced tool prompts."
fi

export INSTALL_NGINX
export INSTALL_DOCKER
export INSTALL_NVM

# Show summary of inputs
echo ""
echo -e "${CYAN}===================================${NC}"
echo -e " Summary of Configuration"
echo -e "${CYAN}===================================${NC}"
echo -e " Username:       ${GREEN}$USERNAME${NC}"
echo -e " Public Key:     ${GREEN}$PUBLIC_KEY${NC}"
echo -e " Install Nginx:  ${GREEN}$INSTALL_NGINX${NC}"
echo -e " Install Docker: ${GREEN}$INSTALL_DOCKER${NC}"
echo -e " Install NVM:    ${GREEN}$INSTALL_NVM${NC}"
echo -e "${CYAN}===================================${NC}"
echo ""

if ! confirm "Looks good? Start installation?"; then
    log "Installation aborted by the user."
    exit 0
fi

echo -e "\n${CYAN}Starting installation steps...${NC}\n"

# Execute Essential steps
for step in "$SCRIPT_DIR"/steps/essentials/*.sh; do
    if [ -f "$step" ]; then
        bash "$step"
    fi
done

# Execute Advanced steps
for step in "$SCRIPT_DIR"/steps/advanced/*.sh; do
    if [ -f "$step" ]; then
        bash "$step"
    fi
done

# Execute Finalize step
if [ -f "$SCRIPT_DIR/steps/finalize.sh" ]; then
    bash "$SCRIPT_DIR/steps/finalize.sh"
fi

echo ""
echo -e "${CYAN}===================================${NC}"
log "✅ All steps completed successfully!"
echo -e "${CYAN}👉 Now login using:${NC}"
PUBLIC_IP=$(curl -s4 ifconfig.me || curl -s4 ipv4.icanhazip.com || curl -s4 api.ipify.org || curl -s6 ifconfig.me || echo "YOUR_SERVER_IP")
echo -e "${GREEN}ssh $USERNAME@$PUBLIC_IP${NC}"
echo -e "${CYAN}===================================${NC}"

