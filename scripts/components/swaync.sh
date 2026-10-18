#!/usr/bin/env bash

## Component : SwayNC Theme Switcher
## Purpose   : Set SwayNC notification center theme programmatically and reload

SWAYNC_COLORS_DIR="${HOME}/.config/swaync/colors"
SWAYNC_CURRENT_FILE="${SWAYNC_COLORS_DIR}/current.css"

get_swaync_theme() {
    if [[ -f "$SWAYNC_CURRENT_FILE" ]]; then
        grep -oP '@import "\K[^.]+' "$SWAYNC_CURRENT_FILE" 2>/dev/null
    fi
}

apply_swaync_theme() {
    local theme="$1"

    if [[ -z "$theme" ]]; then
        echo "Error [swaync]: No theme specified." >&2
        return 1
    fi

    if [[ ! -d "$SWAYNC_COLORS_DIR" ]]; then
        echo "Error [swaync]: Colors directory not found at $SWAYNC_COLORS_DIR" >&2
        return 1
    fi

    local theme_file="${SWAYNC_COLORS_DIR}/${theme}.css"
    if [[ ! -f "$theme_file" ]]; then
        echo "Error [swaync]: Theme '$theme' not found at $theme_file" >&2
        return 1
    fi

    cat <<EOF > "$SWAYNC_CURRENT_FILE"
/**
 * Current Active Color Scheme for SwayNC
 * Automatically updated by global theme selector
 **/

@import "${theme}.css";
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
        apply_swaync_theme "$1"
    else
        echo "Current SwayNC theme: $(get_swaync_theme)"
        echo "Usage: $0 <theme-name>"
        exit 1
    fi
fi
