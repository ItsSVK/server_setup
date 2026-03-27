#!/usr/bin/env bash
set -e

# Resolve the project root assuming this script is in `steps/`
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
source "$PROJECT_ROOT/lib/common.sh"
source "$PROJECT_ROOT/lib/env.sh"

step_info "Configuring Fail2Ban"

if [ ! -f /etc/fail2ban/jail.local ]; then
    log "Creating jail.local from jail.conf..."
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
else
    log "jail.local already exists."
fi

log "Ensuring sshd protection is enabled..."
if grep -q "^\[sshd\]" /etc/fail2ban/jail.local; then
    # Enable sshd jail
    sed -i "/^\[sshd\]/,/^\[/{s/enabled = false/enabled = true/}" /etc/fail2ban/jail.local
    
    if ! grep -q "bantime = 3600" /etc/fail2ban/jail.local; then
        sed -i "/^\[sshd\]/a bantime = 3600" /etc/fail2ban/jail.local
        log "Set sshd bantime to 3600."
    fi

    if ! grep -q "maxretry = 5" /etc/fail2ban/jail.local; then
        sed -i "/^\[sshd\]/a maxretry = 5" /etc/fail2ban/jail.local
        log "Set sshd maxretry to 5."
    fi
else
    warn "Could not find [sshd] section in jail.local. Fail2ban ssh protection might not be enabled properly."
fi

log "Enabling and restarting fail2ban service..."
systemctl enable fail2ban >/dev/null 2>&1
systemctl restart fail2ban >/dev/null 2>&1

log "Fail2Ban configured and restarted."
