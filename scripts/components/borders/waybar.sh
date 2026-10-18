#!/usr/bin/env bash

## Component : Waybar Borders Switcher
## Purpose   : Set Waybar module borders & corner radius programmatically and reload

WAYBAR_BORDERS_DIR="${HOME}/.config/waybar/borders"
WAYBAR_CURRENT_FILE="${WAYBAR_BORDERS_DIR}/current.css"

get_waybar_border() {
    if [[ -f "$WAYBAR_CURRENT_FILE" ]]; then
        grep -oP '@import "\K[^.]+' "$WAYBAR_CURRENT_FILE" 2>/dev/null
    fi
}

apply_waybar_border() {
    local preset="$1"

    if [[ -z "$preset" ]]; then
        echo "Error [waybar]: No border preset specified." >&2
        return 1
    fi

    if [[ ! -d "$WAYBAR_BORDERS_DIR" ]]; then
        echo "Error [waybar]: Borders directory not found at $WAYBAR_BORDERS_DIR" >&2
        return 1
    fi

    local preset_file="${WAYBAR_BORDERS_DIR}/${preset}.css"
    if [[ ! -f "$preset_file" ]]; then
        echo "Error [waybar]: Border preset '$preset' not found at $preset_file" >&2
        return 1
    fi

    cat <<EOF > "$WAYBAR_CURRENT_FILE"
/**
 * Current Active Border Preset for Waybar
 * Automatically updated by global border selector
 **/

@import "${preset}.css";
EOF

    # Reload Waybar with new CSS
    killall -SIGUSR2 waybar 2>/dev/null || true

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_waybar_border "$1"
    else
        echo "Current Waybar border preset: $(get_waybar_border)"
        echo "Usage: $0 <preset-name>"
        exit 1
    fi
fi
