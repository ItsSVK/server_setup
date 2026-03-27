#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/advanced/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/ui.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Installing and configuring Node Version Manager (NVM)"

if [ "${INSTALL_NVM:-no}" != "yes" ]; then
    log "Skipping NVM setup as per user choice."
    exit 0
fi

if [ -z "$USERNAME" ]; then
    warn "USERNAME is not set. Skipping NVM installation."
    exit 0
fi

USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
NVM_DIR="$USER_HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    log "NVM is already installed in $NVM_DIR."
else
    # Install NVM securely as the target user
    run_with_loader "Downloading & Installing NVM v0.40.4" sudo -i -u "$USERNAME" bash -c 'curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
    
    # Ensure profile sourcing if auto-install missed it
    BASHRC="$USER_HOME/.bashrc"
    if ! sudo -i -u "$USERNAME" grep -q 'NVM_DIR' "$BASHRC" 2>/dev/null; then
        warn "NVM configuration missing in .bashrc, injecting manually..."
        sudo -i -u "$USERNAME" bash -c 'cat << '\''EOF'\'' >> ~/.bashrc

# NVM Configuration
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF'
    fi

    # Validate the installation hook
    if sudo -i -u "$USERNAME" bash -c 'source ~/.nvm/nvm.sh && command -v nvm' >/dev/null 2>&1; then
        log "✅ NVM successfully installed and sourced into profile for $USERNAME."
        
        # Install latest LTS Node.js and set as default
        run_with_loader "Installing Node.js (LTS) via NVM" sudo -i -u "$USERNAME" bash -c 'source ~/.nvm/nvm.sh && nvm install --lts && nvm use --lts && nvm alias default "lts/*"'
    else
        warn "NVM installed but might require a shell restart to function."
    fi
fi
