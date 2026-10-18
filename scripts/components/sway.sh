#!/usr/bin/env bash

## Component : Sway Window Colors Theme Switcher
## Purpose   : Set Sway window border color scheme programmatically and reload

SWAY_COLORS_DIR="${HOME}/.config/sway/colors"
SWAY_CURRENT_FILE="${SWAY_COLORS_DIR}/current.conf"

get_sway_theme() {
    if [[ -f "$SWAY_CURRENT_FILE" ]]; then
        grep -oP 'include ./\K[^.]+' "$SWAY_CURRENT_FILE" 2>/dev/null
    fi
}

apply_sway_theme() {
    local theme="$1"

    if [[ -z "$theme" ]]; then
        echo "Error [sway]: No theme specified." >&2
        return 1
    fi

    if [[ ! -d "$SWAY_COLORS_DIR" ]]; then
        echo "Error [sway]: Colors directory not found at $SWAY_COLORS_DIR" >&2
        return 1
    fi

    local theme_file="${SWAY_COLORS_DIR}/${theme}.conf"
    if [[ ! -f "$theme_file" ]]; then
        echo "Error [sway]: Theme '$theme' not found at $theme_file" >&2
        return 1
    fi

    cat <<EOF > "$SWAY_CURRENT_FILE"
# Current Active Color Scheme for Sway
# Automatically updated by global theme selector

include ./${theme}.conf
EOF

    # Reload Sway if running
    if command -v swaymsg &>/dev/null && [[ -n "$SWAYSOCK" ]]; then
        swaymsg reload 2>/dev/null || true
    fi

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_sway_theme "$1"
    else
        echo "Current Sway theme: $(get_sway_theme)"
        echo "Usage: $0 <theme-name>"
        exit 1
    fi
fi
