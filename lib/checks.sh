#!/usr/bin/env bash

check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root. Please use sudo."
    fi
}

check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
            warn "This script is designed for Ubuntu/Debian. Your OS: $ID"
            if ! confirm "Are you sure you want to continue anyway?"; then
                error "Installation aborted by the user."
            fi
        fi
    else
        error "Cannot determine the OS. /etc/os-release is missing."
    fi
}
