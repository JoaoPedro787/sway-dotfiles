#!/usr/bin/env bash

## Component : Kitty Theme Switcher
## Purpose   : Set Kitty terminal colorscheme programmatically and reload via SIGUSR1

KITTY_DIR="${HOME}/.config/kitty"
KITTY_COLORS_DIR="${KITTY_DIR}/colors"
KITTY_CURRENT_FILE="${KITTY_COLORS_DIR}/current.conf"

get_kitty_theme() {
    if [[ -f "$KITTY_CURRENT_FILE" ]]; then
        grep -oP 'include ./\K[^.]+' "$KITTY_CURRENT_FILE" 2>/dev/null
    fi
}

apply_kitty_theme() {
    local theme="$1"

    if [[ -z "$theme" ]]; then
        echo "Error [kitty]: No theme specified." >&2
        return 1
    fi

    if [[ ! -d "$KITTY_COLORS_DIR" ]]; then
        echo "Error [kitty]: Colors directory not found at $KITTY_COLORS_DIR" >&2
        return 1
    fi

    local theme_file="${KITTY_COLORS_DIR}/${theme}.conf"
    if [[ ! -f "$theme_file" ]]; then
        echo "Error [kitty]: Theme '$theme' not found at $theme_file" >&2
        return 1
    fi

    cat <<EOF > "$KITTY_CURRENT_FILE"
# Current Active Color Scheme for Kitty
# Automatically updated by global theme selector

include ./${theme}.conf
EOF

    # Reload all running Kitty instances dynamically
    killall -SIGUSR1 kitty 2>/dev/null || true

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_kitty_theme "$1"
    else
        echo "Current Kitty theme: $(get_kitty_theme)"
        echo "Usage: $0 <theme-name>"
        exit 1
    fi
fi
