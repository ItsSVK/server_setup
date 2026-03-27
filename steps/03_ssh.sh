#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Configuring SSH"

if [ -z "$USERNAME" ]; then
    error "USERNAME is not set."
fi
if [ -z "$PUBLIC_KEY" ]; then
    error "PUBLIC_KEY is not set."
fi

USER_HOME=$(getent passwd "$USERNAME" | cut -d: -f6)
if [ -z "$USER_HOME" ]; then
    error "Could not determine home directory for user $USERNAME."
fi

SSH_DIR="$USER_HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

log "Setting up SSH directory for $USERNAME..."
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    log "Created SSH directory at $SSH_DIR"
fi

# Add public key
if [ ! -f "$AUTH_KEYS" ]; then
    touch "$AUTH_KEYS"
fi

if ! grep -qxF "$PUBLIC_KEY" "$AUTH_KEYS"; then
    echo "$PUBLIC_KEY" >> "$AUTH_KEYS"
    log "Added public key for $USERNAME"
else
    log "Public key already exists in authorized_keys"
fi

chmod 600 "$AUTH_KEYS"
chown -R "$USERNAME:$USERNAME" "$SSH_DIR"
chown "$USERNAME:$USERNAME" "$USER_HOME"
chmod 755 "$USER_HOME"

log "Hardening SSH configuration..."
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_CHANGED=0

update_sshd_config() {
    local key=$1
    local value=$2
    if grep -q "^$key " "$SSHD_CONFIG"; then
        if ! grep -q "^$key $value" "$SSHD_CONFIG"; then
            sed -i "s/^$key.*/$key $value/" "$SSHD_CONFIG"
            SSHD_CHANGED=1
        fi
    else
        echo "$key $value" >> "$SSHD_CONFIG"
        SSHD_CHANGED=1
    fi
}

update_sshd_config "PermitRootLogin" "no"
update_sshd_config "PasswordAuthentication" "no"
update_sshd_config "ChallengeResponseAuthentication" "no"
# Older sshd might use KbdInteractiveAuthentication or require it to be configured
if grep -q "^KbdInteractiveAuthentication" "$SSHD_CONFIG"; then
    update_sshd_config "KbdInteractiveAuthentication" "no"
fi
update_sshd_config "PubkeyAuthentication" "yes"

if [ "$SSHD_CHANGED" -eq 1 ]; then
    log "Validating SSH config..."
    if ! sshd -t; then
        error "SSH configuration is invalid. Reverting changes requires manual intervention."
    fi
    systemctl restart ssh
    log "SSH config hardened and service restarted."
else
    log "SSH config is already optimally secured."
fi
