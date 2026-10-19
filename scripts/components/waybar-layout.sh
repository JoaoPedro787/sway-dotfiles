#!/usr/bin/env bash

## Component : Waybar Layout Switcher
## Purpose   : Switch Waybar layouts (config & style) programmatically and restart process

WAYBAR_DIR="${HOME}/.config/waybar"
WAYBAR_LAYOUTS_DIR="${WAYBAR_DIR}/layouts"
WAYBAR_CONFIG_FILE="${WAYBAR_DIR}/config.jsonc"
WAYBAR_STYLE_FILE="${WAYBAR_DIR}/style.css"
WAYBAR_STATE_FILE="${HOME}/.config/.current_waybar_layout"

get_waybar_layout() {
    if [[ -L "$WAYBAR_CONFIG_FILE" ]]; then
        local target
        target=$(readlink "$WAYBAR_CONFIG_FILE")
        basename "$(dirname "$target")"
    elif [[ -f "$WAYBAR_STATE_FILE" ]]; then
        cat "$WAYBAR_STATE_FILE"
    else
        echo "default"
    fi
}

apply_waybar_layout() {
    local layout="$1"

    if [[ -z "$layout" ]]; then
        echo "Error [waybar-layout]: No layout specified." >&2
        return 1
    fi

    if [[ ! -d "$WAYBAR_LAYOUTS_DIR" ]]; then
        echo "Error [waybar-layout]: Layouts directory not found at $WAYBAR_LAYOUTS_DIR" >&2
        return 1
    fi

    local target_dir="${WAYBAR_LAYOUTS_DIR}/${layout}"
    if [[ ! -d "$target_dir" ]]; then
        echo "Error [waybar-layout]: Layout '$layout' not found at $target_dir" >&2
        return 1
    fi

    if [[ ! -f "${target_dir}/config.jsonc" ]]; then
        echo "Error [waybar-layout]: Layout '$layout' missing config.jsonc" >&2
        return 1
    fi

    if [[ ! -f "${target_dir}/style.css" ]]; then
        echo "Error [waybar-layout]: Layout '$layout' missing style.css" >&2
        return 1
    fi

    # Ensure layout has access to shared colors and borders
    if [[ ! -e "${target_dir}/colors" ]]; then
        ln -sfn ../../colors "${target_dir}/colors" 2>/dev/null || true
    fi
    if [[ ! -e "${target_dir}/borders" ]]; then
        ln -sfn ../../borders "${target_dir}/borders" 2>/dev/null || true
    fi

    # Update relative symlinks in ~/.config/waybar
    (
        cd "$WAYBAR_DIR" && \
        ln -sfn "layouts/${layout}/config.jsonc" "$WAYBAR_CONFIG_FILE" && \
        ln -sfn "layouts/${layout}/style.css" "$WAYBAR_STYLE_FILE"
    )

    # Save active state
    echo "$layout" > "$WAYBAR_STATE_FILE"

    # Restart Waybar process to apply new config.jsonc and style.css
    killall waybar 2>/dev/null || true
    for _ in {1..10}; do
        pgrep -u "$USER" -x waybar >/dev/null || break
        sleep 0.1
    done

    if command -v swaymsg &>/dev/null && [[ -n "$SWAYSOCK" ]]; then
        swaymsg exec waybar >/dev/null 2>&1 || true
    else
        nohup waybar >/dev/null 2>&1 &
    fi

    return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ -n "$1" ]]; then
        apply_waybar_layout "$1"
    else
        echo "Current Waybar layout: $(get_waybar_layout)"
        echo "Available layouts:"
        if [[ -d "$WAYBAR_LAYOUTS_DIR" ]]; then
            for d in "${WAYBAR_LAYOUTS_DIR}"/*/; do
                [[ -d "$d" ]] && echo "  - $(basename "$d")"
            done
        fi
        echo "Usage: $0 <layout-name>"
        exit 1
    fi
fi
