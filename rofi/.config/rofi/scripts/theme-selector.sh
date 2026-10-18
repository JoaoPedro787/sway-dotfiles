#!/usr/bin/env bash

## Author  : João Fedora / Antigravity
## Purpose : Interactively select and switch the global Rofi color scheme

COLORS_DIR="$HOME/.config/rofi/colors"
CURRENT_FILE="$COLORS_DIR/current.rasi"

# Ensure colors directory and current.rasi exist
if [[ ! -d "$COLORS_DIR" ]]; then
    notify-send "Rofi Theme" "Error: Colors directory not found at $COLORS_DIR"
    exit 1
fi

# Get current theme name
current_theme=""
if [[ -f "$CURRENT_FILE" ]]; then
    current_theme=$(grep -oP '@import "\K[^.]+' "$CURRENT_FILE")
fi

# List all available themes except current.rasi
themes=$(find "$COLORS_DIR" -maxdepth 1 -name "*.rasi" ! -name "current.rasi" -exec basename -s .rasi {} + | sort)

# Pre-select current theme in rofi if found
selected_row=0
idx=0
while IFS= read -r theme; do
    if [[ "$theme" == "$current_theme" ]]; then
        selected_row=$idx
        break
    fi
    ((idx++))
done <<< "$themes"

# Prompt user via rofi
chosen=$(echo "$themes" | rofi -dmenu -i -selected-row "$selected_row" -p "󰔎 Color Scheme" -mesg "Current: ${current_theme:-None}")

# If user cancelled or selected empty string
if [[ -z "$chosen" ]]; then
    exit 0
fi

# Verify the chosen scheme exists
if [[ -f "$COLORS_DIR/${chosen}.rasi" ]]; then
    cat <<EOF > "$CURRENT_FILE"
/**
 * Current Active Color Scheme for Rofi
 * Automatically updated by ~/.config/rofi/scripts/theme-selector.sh
 **/

@import "${chosen}.rasi"
EOF

    if command -v notify-send &>/dev/null; then
        notify-send "Rofi Theme" "Color scheme switched to: $chosen" -i preferences-desktop-theme
    fi
else
    if command -v notify-send &>/dev/null; then
        notify-send "Rofi Theme" "Error: Theme $chosen not found!"
    fi
fi
