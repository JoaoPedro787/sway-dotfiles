#!/usr/bin/env bash

## Component : SwayNC Borders Switcher
## Purpose   : Set SwayNC notification center borders & corner radius programmatically and reload

SWAYNC_BORDERS_DIR="${HOME}/.config/swaync/borders"
SWAYNC_CURRENT_FILE="${SWAYNC_BORDERS_DIR}/current.css"

get_swaync_border() {
    if [[ -f "$SWAYNC_CURRENT_FILE" ]]; then
        grep -oP '@import "\K[^.]+' "$SWAYNC_CURRENT_FILE" 2>/dev/null
    fi
}

apply_swaync_border() {
    local preset="$1"

    if [[ -z "$preset" ]]; then
        echo "Error [swaync]: No border preset specified." >&2
        return 1
    fi

    if [[ ! -d "$SWAYNC_BORDERS_DIR" ]]; then
        echo "Error [swaync]: Borders directory not found at $SWAYNC_BORDERS_DIR" >&2
        return 1
    fi

    local preset_file="${SWAYNC_BORDERS_DIR}/${preset}.css"
    if [[ ! -f "$preset_file" ]]; then
        echo "Error [swaync]: Border preset '$preset' not found at $preset_file" >&2
        return 1
    fi

    cat <<EOF > "$SWAYNC_CURRENT_FILE"
/**
 * Current Active Border Preset for SwayNC
 * Automatically updated by global border selector
 **/

@import "${preset}.css";
EOF

    # Reload SwayNC styles
    if command -v swaync-client &>/dev/null; then
        swaync-client -rs 2>/dev/null || true
        swaync-client -R 2>/dev/null || true
    fi

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_swaync_border "$1"
    else
        echo "Current SwayNC border preset: $(get_swaync_border)"
        echo "Usage: $0 <preset-name>"
        exit 1
    fi
fi
