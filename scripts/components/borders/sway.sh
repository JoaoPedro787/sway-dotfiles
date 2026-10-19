#!/usr/bin/env bash

## Component : Sway Window Borders Switcher
## Purpose   : Set Sway window borders & corner radius programmatically and reload

SWAY_BORDERS_DIR="${HOME}/.config/sway/borders"
SWAY_CURRENT_FILE="${SWAY_BORDERS_DIR}/current.conf"

get_sway_border() {
    if [[ -f "$SWAY_CURRENT_FILE" ]]; then
        grep -oP 'include ./\K[^.]+' "$SWAY_CURRENT_FILE" 2>/dev/null
    fi
}

apply_sway_border() {
    local preset="$1"

    if [[ -z "$preset" ]]; then
        echo "Error [sway]: No border preset specified." >&2
        return 1
    fi

    if [[ ! -d "$SWAY_BORDERS_DIR" ]]; then
        echo "Error [sway]: Borders directory not found at $SWAY_BORDERS_DIR" >&2
        return 1
    fi

    local preset_file="${SWAY_BORDERS_DIR}/${preset}.conf"
    if [[ ! -f "$preset_file" ]]; then
        echo "Error [sway]: Border preset '$preset' not found at $preset_file" >&2
        return 1
    fi

    cat <<EOF > "$SWAY_CURRENT_FILE"
# Current Active Border Preset for Sway
# Automatically updated by global border selector

include ./${preset}.conf
EOF

    # Reload Sway and update existing windows
    if command -v swaymsg &>/dev/null && [[ -n "$SWAYSOCK" ]]; then
        swaymsg reload 2>/dev/null || true
        if [[ "$preset" == *"-none" ]]; then
            swaymsg "[app_id=.*] border none" 2>/dev/null || true
            swaymsg "[class=.*] border none" 2>/dev/null || true
        elif [[ "$preset" == *"-colored" ]]; then
            swaymsg "[app_id=.*] border pixel 1" 2>/dev/null || true
            swaymsg "[class=.*] border pixel 1" 2>/dev/null || true
        fi
    fi

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_sway_border "$1"
    else
        echo "Current Sway border preset: $(get_sway_border)"
        echo "Usage: $0 <preset-name>"
        exit 1
    fi
fi
