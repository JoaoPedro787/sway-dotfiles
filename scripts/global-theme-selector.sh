#!/usr/bin/env bash

## Author  : João Fedora / Antigravity
## Purpose : Unified Global Theme Switcher for Sway Suite (Kitty, Rofi, Swaylock, SwayNC, Waybar)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPONENTS_DIR="${SCRIPT_DIR}/components"

# Source component modules
for comp in rofi waybar swaync swaylock kitty sway; do
    if [[ -f "${COMPONENTS_DIR}/${comp}.sh" ]]; then
        # shellcheck source=/dev/null
        source "${COMPONENTS_DIR}/${comp}.sh"
    else
        echo "Error: Component module '${comp}.sh' not found in ${COMPONENTS_DIR}" >&2
        exit 1
    fi
done

# Curated list of global themes
AVAILABLE_THEMES=(
    "nord"
    "gruvbox"
    "catppuccin-mocha"
)

# Detect current active theme (checks kitty, rofi, or fallback state)
STATE_FILE="${HOME}/.config/.current_theme"
current_theme=""
if [[ -f "$STATE_FILE" ]]; then
    current_theme=$(tr -d '[:space:]' < "$STATE_FILE")
fi
if [[ -z "$current_theme" ]]; then
    current_theme=$(get_rofi_theme 2>/dev/null || get_kitty_theme 2>/dev/null || echo "")
fi

# Determine theme from argument or interactive Rofi menu
chosen="$1"

if [[ -z "$chosen" ]]; then
    selected_row=0
    idx=0
    for theme in "${AVAILABLE_THEMES[@]}"; do
        if [[ "$theme" == "$current_theme" ]]; then
            selected_row=$idx
            break
        fi
        ((idx++))
    done

    chosen=$(printf "%s\n" "${AVAILABLE_THEMES[@]}" | rofi -dmenu -i -selected-row "$selected_row" -p "󰔎 Global Theme" -mesg "Current: ${current_theme:-None}" || true)
fi

# Exit if cancelled or empty
if [[ -z "$chosen" ]]; then
    exit 0
fi

# Validate theme exists in curated list
valid=0
for theme in "${AVAILABLE_THEMES[@]}"; do
    if [[ "$theme" == "$chosen" ]]; then
        valid=1
        break
    fi
done

if [[ $valid -eq 0 ]]; then
    msg="Invalid theme '$chosen'. Available options: ${AVAILABLE_THEMES[*]}"
    echo "Error: $msg" >&2
    if command -v notify-send &>/dev/null; then
        notify-send "Global Theme" "$msg" -i dialog-error
    fi
    exit 1
fi

echo "Applying global theme: $chosen"
errors=()

# Apply to Kitty
if ! apply_kitty_theme "$chosen"; then
    errors+=("kitty")
fi

# Apply to Rofi
if ! apply_rofi_theme "$chosen"; then
    errors+=("rofi")
fi

# Apply to Swaylock
if ! apply_swaylock_theme "$chosen"; then
    errors+=("swaylock")
fi

# Apply to SwayNC
if ! apply_swaync_theme "$chosen"; then
    errors+=("swaync")
fi

# Apply to Waybar
if ! apply_waybar_theme "$chosen"; then
    errors+=("waybar")
fi

# Apply to Sway
if ! apply_sway_theme "$chosen"; then
    errors+=("sway")
fi

# Save state
echo "$chosen" > "$STATE_FILE"

# Report results
if [[ ${#errors[@]} -eq 0 ]]; then
    echo "Successfully updated all components to theme: $chosen"
    if command -v notify-send &>/dev/null; then
        notify-send "Global Theme" "Color scheme switched to: $chosen" -i preferences-desktop-theme
    fi
    exit 0
else
    msg="Theme '$chosen' applied with warnings. Failed components: ${errors[*]}"
    echo "Warning: $msg" >&2
    if command -v notify-send &>/dev/null; then
        notify-send "Global Theme" "$msg" -i dialog-warning
    fi
    exit 1
fi
