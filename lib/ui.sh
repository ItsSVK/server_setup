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
        read -n 1 -p "$(echo -e "${YELLOW}?${NC} ${question} [y/n]: ")" answer
        echo # print a newline for clean output
        case $(echo "$answer" | tr '[:upper:]' '[:lower:]') in
            y) return 0 ;;
            n|"") return 1 ;;
            *) echo -e "${RED}Please answer y or n.${NC}" >&2 ;;
        esac
    done
}

# Run a command with a spinner and hide its output unless it fails
run_with_loader() {
    local message="$1"
    shift
    
    local tmp_log=$(mktemp)
    
    # Run the command in the background
    "$@" > "$tmp_log" 2>&1 &
    local pid=$!
    
    local spins=( "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏" )
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        printf "\r${CYAN}%s${NC} %s..." "${spins[$i]}" "$message"
        i=$(( (i+1) % 10 ))
        sleep 0.1
    done
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        printf "\r\033[K${GREEN}✅${NC} %s\n" "$message"
    else
        printf "\r\033[K${RED}❌${NC} %s (Failed)\n" "$message"
        echo -e "${RED}--- Error Log ---${NC}"
        cat "$tmp_log"
        echo -e "${RED}-----------------${NC}"
        rm -f "$tmp_log"
        return $exit_code
    fi
    rm -f "$tmp_log"
}
