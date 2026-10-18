#!/usr/bin/env bash

## Author  : João Fedora / Antigravity
## Purpose : Select and switch the active SwayNC color scheme

COLORS_DIR="$HOME/.config/swaync/colors"
CURRENT_FILE="$COLORS_DIR/current.css"

if [[ ! -d "$COLORS_DIR" ]]; then
    notify-send "SwayNC Theme" "Error: Colors directory not found at $COLORS_DIR"
    exit 1
fi

# Detect current theme
current_theme=""
if [[ -f "$CURRENT_FILE" ]]; then
    current_theme=$(grep -oP '@import "\K[^.]+' "$CURRENT_FILE")
fi

# Determine chosen theme from CLI argument or Rofi menu
chosen="$1"

if [[ -z "$chosen" ]]; then
    themes=$(find "$COLORS_DIR" -maxdepth 1 -name "*.css" ! -name "current.css" -exec basename -s .css {} + | sort)
    
    selected_row=0
    idx=0
    while IFS= read -r theme; do
        if [[ "$theme" == "$current_theme" ]]; then
            selected_row=$idx
            break
        fi
        ((idx++))
    done <<< "$themes"

    chosen=$(echo "$themes" | rofi -dmenu -i -selected-row "$selected_row" -p "󰔎 SwayNC Scheme" -mesg "Current: ${current_theme:-None}")
fi

if [[ -z "$chosen" ]]; then
    exit 0
fi

# Apply theme
if [[ -f "$COLORS_DIR/${chosen}.css" ]]; then
    cat <<EOF > "$CURRENT_FILE"
/**
 * Current Active Color Scheme for SwayNC
 * Automatically updated by ~/.config/swaync/scripts/theme-selector.sh
 **/

@import "${chosen}.css";
EOF

    # Reload SwayNC styles
    if command -v swaync-client &>/dev/null; then
        swaync-client -rs 2>/dev/null || true
        swaync-client -R 2>/dev/null || true
    fi

    if command -v notify-send &>/dev/null; then
        notify-send "SwayNC Theme" "Color scheme switched to: $chosen" -i preferences-desktop-theme
    fi
else
    if command -v notify-send &>/dev/null; then
        notify-send "SwayNC Theme" "Error: Theme $chosen not found!"
    fi
    exit 1
fi
