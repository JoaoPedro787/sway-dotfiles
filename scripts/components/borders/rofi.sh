#!/usr/bin/env bash

## Component : Rofi Borders Switcher
## Purpose   : Set Rofi window border & corner radius programmatically

ROFI_BORDERS_DIR="${HOME}/.config/rofi/borders"
ROFI_CURRENT_FILE="${ROFI_BORDERS_DIR}/current.rasi"

get_rofi_border() {
    if [[ -f "$ROFI_CURRENT_FILE" ]]; then
        grep -oP '@import "\K[^.]+' "$ROFI_CURRENT_FILE" 2>/dev/null
    fi
}

apply_rofi_border() {
    local preset="$1"

    if [[ -z "$preset" ]]; then
        echo "Error [rofi]: No border preset specified." >&2
        return 1
    fi

    if [[ ! -d "$ROFI_BORDERS_DIR" ]]; then
        echo "Error [rofi]: Borders directory not found at $ROFI_BORDERS_DIR" >&2
        return 1
    fi

    local preset_file="${ROFI_BORDERS_DIR}/${preset}.rasi"
    if [[ ! -f "$preset_file" ]]; then
        echo "Error [rofi]: Border preset '$preset' not found at $preset_file" >&2
        return 1
    fi

    cat <<EOF > "$ROFI_CURRENT_FILE"
/**
 * Current Active Border Preset for Rofi
 * Automatically updated by global border selector
 **/

@import "${preset}.rasi"
EOF

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_rofi_border "$1"
    else
        echo "Current Rofi border preset: $(get_rofi_border)"
        echo "Usage: $0 <preset-name>"
        exit 1
    fi
fi
