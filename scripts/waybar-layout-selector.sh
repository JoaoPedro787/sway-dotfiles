#!/usr/bin/env bash

## Author  : João Fedora / Antigravity
## Purpose : Unified Waybar Layout Switcher (Rofi & CLI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPONENTS_DIR="${SCRIPT_DIR}/components"
COMPONENT_FILE="${COMPONENTS_DIR}/waybar-layout.sh"

if [[ ! -f "$COMPONENT_FILE" ]]; then
    echo "Error: Component module 'waybar-layout.sh' not found in ${COMPONENTS_DIR}" >&2
    exit 1
fi

# shellcheck source=/dev/null
source "$COMPONENT_FILE"

# Friendly labels for known layouts
declare -A LAYOUT_LABELS=(
    ["default"]="󰓎 Default - Layout Padrão Completo"
    ["example"]="󰓎 Example - Barra Flutuante com Relógio Central"
    ["retro"]="󰓎 Retro - Barra Retrô Minimalista"
    ["block-1"]="󰓎 Block 1 - Badges Coloridos e Bordas Sólidas"
    ["block-2"]="󰓎 Block 2 - Ícones Coloridos e Contornos"
    ["block-3"]="󰓎 Block 3 - Módulos em Bloco Uniforme"
    ["block-4"]="󰓎 Block 4 - Barra Contínua com Relógio à Direita"
)

# Discover all available layouts dynamically
AVAILABLE_LAYOUTS=()
if [[ -d "$WAYBAR_LAYOUTS_DIR" ]]; then
    for dir in "${WAYBAR_LAYOUTS_DIR}"/*/; do
        if [[ -d "$dir" ]]; then
            name="$(basename "$dir")"
            if [[ -f "${dir}/config.jsonc" && -f "${dir}/style.css" ]]; then
                AVAILABLE_LAYOUTS+=("$name")
            fi
        fi
    done
fi

if [[ ${#AVAILABLE_LAYOUTS[@]} -eq 0 ]]; then
    echo "Error: No valid layouts found in ${WAYBAR_LAYOUTS_DIR}" >&2
    exit 1
fi

# Helper functions
get_label() {
    local id="$1"
    if [[ -n "${LAYOUT_LABELS[$id]}" ]]; then
        echo "${LAYOUT_LABELS[$id]}"
    else
        echo "󰓎 $id"
    fi
}

current_layout="$(get_waybar_layout)"

# Handle CLI flags
case "$1" in
    -h|--help)
        echo "Usage: $0 [options] [layout_name]"
        echo ""
        echo "Options:"
        echo "  -l, --list      List available layouts"
        echo "  -c, --current   Show currently active layout"
        echo "  -h, --help      Show this help message"
        echo ""
        echo "If no arguments are provided, opens an interactive Rofi menu."
        exit 0
        ;;
    -l|--list)
        echo "Available Waybar layouts:"
        for l in "${AVAILABLE_LAYOUTS[@]}"; do
            prefix="  "
            [[ "$l" == "$current_layout" ]] && prefix="* "
            echo "${prefix}${l} - $(get_label "$l")"
        done
        exit 0
        ;;
    -c|--current)
        echo "$current_layout"
        exit 0
        ;;
esac

chosen_arg="$1"
chosen=""

if [[ -n "$chosen_arg" ]]; then
    # Direct CLI match (by ID or full label)
    for l in "${AVAILABLE_LAYOUTS[@]}"; do
        if [[ "$l" == "$chosen_arg" || "$(get_label "$l")" == "$chosen_arg" ]]; then
            chosen="$l"
            break
        fi
    done
else
    # Interactive Rofi menu
    selected_row=0
    idx=0
    menu_items=()
    for l in "${AVAILABLE_LAYOUTS[@]}"; do
        label="$(get_label "$l")"
        menu_items+=("$label")
        if [[ "$l" == "$current_layout" ]]; then
            selected_row=$idx
        fi
        ((idx++))
    done

    current_label="$(get_label "$current_layout")"
    chosen_label=$(printf "%s\n" "${menu_items[@]}" | rofi -dmenu -i -selected-row "$selected_row" -p "󰓎 Waybar Layout" -mesg "Current: ${current_label}" || true)

    if [[ -z "$chosen_label" ]]; then
        exit 0
    fi

    for l in "${AVAILABLE_LAYOUTS[@]}"; do
        if [[ "$(get_label "$l")" == "$chosen_label" || "$l" == "$chosen_label" ]]; then
            chosen="$l"
            break
        fi
    done
fi

# Exit if cancelled or invalid
if [[ -z "$chosen" ]]; then
    msg="Invalid Waybar layout: '$chosen_arg'. Available options: ${AVAILABLE_LAYOUTS[*]}"
    echo "Error: $msg" >&2
    if command -v notify-send &>/dev/null; then
        notify-send "Waybar Layout" "$msg" -i dialog-error
    fi
    exit 1
fi

echo "Applying Waybar layout: $chosen"

if apply_waybar_layout "$chosen"; then
    display_label="$(get_label "$chosen")"
    echo "Successfully activated Waybar layout: $chosen"
    if command -v notify-send &>/dev/null; then
        notify-send "Waybar Layout" "Active layout: $display_label" -i preferences-desktop-theme
    fi
    exit 0
else
    msg="Failed to apply Waybar layout '$chosen'."
    echo "Error: $msg" >&2
    if command -v notify-send &>/dev/null; then
        notify-send "Waybar Layout" "$msg" -i dialog-warning
    fi
    exit 1
fi
