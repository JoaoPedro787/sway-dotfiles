#!/usr/bin/env bash

## Component : Swaylock Theme Switcher
## Purpose   : Set Swaylock color scheme programmatically

SWAYLOCK_DIR="${HOME}/.config/swaylock"
SWAYLOCK_COLORS_DIR="${SWAYLOCK_DIR}/colors"
SWAYLOCK_BASE_FILE="${SWAYLOCK_DIR}/base"
SWAYLOCK_CURRENT_FILE="${SWAYLOCK_COLORS_DIR}/current.conf"
SWAYLOCK_CONFIG_FILE="${SWAYLOCK_DIR}/config"

get_swaylock_theme() {
    if [[ -f "$SWAYLOCK_CURRENT_FILE" ]]; then
        tr -d '[:space:]' < "$SWAYLOCK_CURRENT_FILE"
    fi
}

apply_swaylock_theme() {
    local theme="$1"

    if [[ -z "$theme" ]]; then
        echo "Error [swaylock]: No theme specified." >&2
        return 1
    fi

    if [[ ! -d "$SWAYLOCK_COLORS_DIR" || ! -f "$SWAYLOCK_BASE_FILE" ]]; then
        echo "Error [swaylock]: Colors directory or base configuration file not found at $SWAYLOCK_DIR" >&2
        return 1
    fi

    local theme_file="${SWAYLOCK_COLORS_DIR}/${theme}.conf"
    if [[ ! -f "$theme_file" ]]; then
        echo "Error [swaylock]: Theme '$theme' not found at $theme_file" >&2
        return 1
    fi

    # Merge base configuration with the chosen color palette
    cat "$SWAYLOCK_BASE_FILE" "$theme_file" > "$SWAYLOCK_CONFIG_FILE"
    echo "$theme" > "$SWAYLOCK_CURRENT_FILE"

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_swaylock_theme "$1"
    else
        echo "Current Swaylock theme: $(get_swaylock_theme)"
        echo "Usage: $0 <theme-name>"
        exit 1
    fi
fi
