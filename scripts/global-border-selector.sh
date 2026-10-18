#!/usr/bin/env bash

## Author  : João Fedora / Antigravity
## Purpose : Unified Global Border & Radius Switcher for Sway Suite (SwayFX, Waybar, SwayNC, Rofi)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPONENTS_DIR="${SCRIPT_DIR}/components/borders"

# Source component modules
for comp in sway waybar swaync rofi; do
    if [[ -f "${COMPONENTS_DIR}/${comp}.sh" ]]; then
        # shellcheck source=/dev/null
        source "${COMPONENTS_DIR}/${comp}.sh"
    else
        echo "Error: Border component module '${comp}.sh' not found in ${COMPONENTS_DIR}" >&2
        exit 1
    fi
done

# Curated list of border presets
AVAILABLE_PRESETS=(
    "sharp-none"
    "sharp-colored"
    "rounded-none"
    "rounded-colored"
    "extra-none"
    "extra-colored"
)

declare -A PRESET_LABELS=(
    ["sharp-none"]="󰓎 Sharp (0px) - Sem Borda"
    ["sharp-colored"]="󰓎 Sharp (0px) - Com Borda Colorida"
    ["rounded-none"]="󰓎 Rounded (10px) - Sem Borda"
    ["rounded-colored"]="󰓎 Rounded (10px) - Com Borda Colorida"
    ["extra-none"]="󰓎 Extra Rounded (18px) - Sem Borda"
    ["extra-colored"]="󰓎 Extra Rounded (18px) - Com Borda Colorida"
)

# Detect current active preset
STATE_FILE="${HOME}/.config/.current_border"
current_border=""
if [[ -f "$STATE_FILE" ]]; then
    current_border=$(tr -d '[:space:]' < "$STATE_FILE")
fi
if [[ -z "$current_border" ]]; then
    current_border=$(get_sway_border 2>/dev/null || get_waybar_border 2>/dev/null || echo "rounded-none")
fi

# Determine preset from CLI argument or interactive Rofi menu
chosen_arg="$1"
chosen=""

if [[ -n "$chosen_arg" ]]; then
    # Direct CLI match (by ID or full label)
    for preset in "${AVAILABLE_PRESETS[@]}"; do
        if [[ "$preset" == "$chosen_arg" || "${PRESET_LABELS[$preset]}" == "$chosen_arg" ]]; then
            chosen="$preset"
            break
        fi
    done
else
    # Interactive Rofi menu
    selected_row=0
    idx=0
    menu_items=()
    for preset in "${AVAILABLE_PRESETS[@]}"; do
        label="${PRESET_LABELS[$preset]}"
        menu_items+=("$label")
        if [[ "$preset" == "$current_border" ]]; then
            selected_row=$idx
        fi
        ((idx++))
    done

    current_label="${PRESET_LABELS[$current_border]:-$current_border}"
    chosen_label=$(printf "%s\n" "${menu_items[@]}" | rofi -dmenu -i -selected-row "$selected_row" -p "󰓎 Border Style" -mesg "Current: ${current_label:-None}" || true)

    if [[ -z "$chosen_label" ]]; then
        exit 0
    fi

    for preset in "${AVAILABLE_PRESETS[@]}"; do
        if [[ "${PRESET_LABELS[$preset]}" == "$chosen_label" || "$preset" == "$chosen_label" ]]; then
            chosen="$preset"
            break
        fi
    done
fi

# Exit if cancelled or empty
if [[ -z "$chosen" ]]; then
    msg="Invalid border preset selection: '$chosen_arg'."
    echo "Error: $msg Available options: ${AVAILABLE_PRESETS[*]}" >&2
    if command -v notify-send &>/dev/null; then
        notify-send "Global Borders" "$msg" -i dialog-error
    fi
    exit 1
fi

echo "Applying global border preset: $chosen"
errors=()

# Apply to Sway / SwayFX
if ! apply_sway_border "$chosen"; then
    errors+=("sway")
fi

# Apply to Waybar
if ! apply_waybar_border "$chosen"; then
    errors+=("waybar")
fi

# Apply to SwayNC
if ! apply_swaync_border "$chosen"; then
    errors+=("swaync")
fi

# Apply to Rofi
if ! apply_rofi_border "$chosen"; then
    errors+=("rofi")
fi

# Save state
echo "$chosen" > "$STATE_FILE"

# Report results
display_name="${PRESET_LABELS[$chosen]:-$chosen}"
if [[ ${#errors[@]} -eq 0 ]]; then
    echo "Successfully updated all components to border preset: $chosen"
    if command -v notify-send &>/dev/null; then
        notify-send "Global Borders" "Style switched to: $display_name" -i preferences-desktop-theme
    fi
    exit 0
else
    msg="Border preset '$chosen' applied with warnings. Failed components: ${errors[*]}"
    echo "Warning: $msg" >&2
    if command -v notify-send &>/dev/null; then
        notify-send "Global Borders" "$msg" -i dialog-warning
    fi
    exit 1
fi
