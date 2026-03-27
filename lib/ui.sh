#!/usr/bin/env bash

# Prompt for a value, with an optional default
ask() {
    local question=$1
    local default=$2
    local answer
    
    if [ -n "$default" ]; then
        read -p "$(echo -e "${YELLOW}?${NC} ${question} [${default}]: ")" answer
        echo "${answer:-$default}"
    else
        while true; do
            read -p "$(echo -e "${YELLOW}?${NC} ${question}: ")" answer
            if [ -n "$answer" ]; then
                echo "$answer"
                break
            fi
        done
    fi
}

# Prompt for a yes/no confirmation
confirm() {
    local question=$1
    local answer
    
    while true; do
        read -p "$(echo -e "${YELLOW}?${NC} ${question} [y/N]: ")" answer
        case $(echo "$answer" | tr '[:upper:]' '[:lower:]') in
            y|yes) return 0 ;;
            n|no|"") return 1 ;;
            *) echo -e "${RED}Please answer y or n.${NC}" >&2 ;;
        esac
    done
}
