#!/usr/bin/env bash

## Component : Rofi Theme Switcher
## Purpose   : Set Rofi theme programmatically without user prompt

ROFI_COLORS_DIR="${HOME}/.config/rofi/colors"
ROFI_CURRENT_FILE="${ROFI_COLORS_DIR}/current.rasi"

get_rofi_theme() {
    if [[ -f "$ROFI_CURRENT_FILE" ]]; then
        grep -oP '@import "\K[^.]+' "$ROFI_CURRENT_FILE" 2>/dev/null
    fi
}

apply_rofi_theme() {
    local theme="$1"

    if [[ -z "$theme" ]]; then
        echo "Error [rofi]: No theme specified." >&2
        return 1
    fi

    if [[ ! -d "$ROFI_COLORS_DIR" ]]; then
        echo "Error [rofi]: Colors directory not found at $ROFI_COLORS_DIR" >&2
        return 1
    fi

    local theme_file="${ROFI_COLORS_DIR}/${theme}.rasi"
    if [[ ! -f "$theme_file" ]]; then
        echo "Error [rofi]: Theme '$theme' not found at $theme_file" >&2
        return 1
    fi

    cat <<EOF > "$ROFI_CURRENT_FILE"
/**
 * Current Active Color Scheme for Rofi
 * Automatically updated by global theme selector
 **/

@import "${theme}.rasi"
EOF

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_rofi_theme "$1"
    else
        echo "Current Rofi theme: $(get_rofi_theme)"
        echo "Usage: $0 <theme-name>"
        exit 1
    fi
fi
