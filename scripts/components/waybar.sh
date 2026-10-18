#!/usr/bin/env bash

## Component : Waybar Theme Switcher
## Purpose   : Set Waybar theme programmatically and reload bar styles

WAYBAR_COLORS_DIR="${HOME}/.config/waybar/colors"
WAYBAR_CURRENT_FILE="${WAYBAR_COLORS_DIR}/current.css"

get_waybar_theme() {
    if [[ -f "$WAYBAR_CURRENT_FILE" ]]; then
        grep -oP '@import "\K[^.]+' "$WAYBAR_CURRENT_FILE" 2>/dev/null
    fi
}

apply_waybar_theme() {
    local theme="$1"

    if [[ -z "$theme" ]]; then
        echo "Error [waybar]: No theme specified." >&2
        return 1
    fi

    if [[ ! -d "$WAYBAR_COLORS_DIR" ]]; then
        echo "Error [waybar]: Colors directory not found at $WAYBAR_COLORS_DIR" >&2
        return 1
    fi

    local theme_file="${WAYBAR_COLORS_DIR}/${theme}.css"
    if [[ ! -f "$theme_file" ]]; then
        echo "Error [waybar]: Theme '$theme' not found at $theme_file" >&2
        return 1
    fi

    cat <<EOF > "$WAYBAR_CURRENT_FILE"
/**
 * Current Active Color Scheme for Waybar
 * Automatically updated by global theme selector
 **/

@import "${theme}.css";
EOF

    # Reload Waybar with new CSS
    killall -SIGUSR2 waybar 2>/dev/null || true

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_waybar_theme "$1"
    else
        echo "Current Waybar theme: $(get_waybar_theme)"
        echo "Usage: $0 <theme-name>"
        exit 1
    fi
fi
