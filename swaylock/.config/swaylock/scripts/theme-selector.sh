#!/usr/bin/env bash

## Author  : João Fedora / Antigravity
## Purpose : Select and switch the active Swaylock color scheme

SWAYLOCK_DIR="$HOME/.config/swaylock"
COLORS_DIR="$SWAYLOCK_DIR/colors"
BASE_FILE="$SWAYLOCK_DIR/base"
CURRENT_FILE="$COLORS_DIR/current.conf"
CONFIG_FILE="$SWAYLOCK_DIR/config"

if [[ ! -d "$COLORS_DIR" || ! -f "$BASE_FILE" ]]; then
    notify-send "Swaylock Theme" "Error: Directory structure or base file not found at $SWAYLOCK_DIR"
    exit 1
fi

# Detect current theme
current_theme=""
if [[ -f "$CURRENT_FILE" ]]; then
    current_theme=$(cat "$CURRENT_FILE" | tr -d '[:space:]')
fi

# Determine chosen theme from CLI argument or Rofi menu
chosen="$1"

if [[ -z "$chosen" ]]; then
    themes=$(find "$COLORS_DIR" -maxdepth 1 -name "*.conf" ! -name "current.conf" -exec basename -s .conf {} + | sort)
    
    selected_row=0
    idx=0
    while IFS= read -r theme; do
        if [[ "$theme" == "$current_theme" ]]; then
            selected_row=$idx
            break
        fi
        ((idx++))
    done <<< "$themes"

    chosen=$(echo "$themes" | rofi -dmenu -i -selected-row "$selected_row" -p "󰔎 Swaylock Scheme" -mesg "Current: ${current_theme:-None}")
fi

if [[ -z "$chosen" ]]; then
    exit 0
fi

# Apply theme
THEME_FILE="$COLORS_DIR/${chosen}.conf"

if [[ -f "$THEME_FILE" ]]; then
    # Merge base configuration with the chosen color palette
    cat "$BASE_FILE" "$THEME_FILE" > "$CONFIG_FILE"
    echo "$chosen" > "$CURRENT_FILE"

    if command -v notify-send &>/dev/null; then
        notify-send "Swaylock Theme" "Color scheme switched to: $chosen" -i preferences-desktop-theme
    fi
else
    if command -v notify-send &>/dev/null; then
        notify-send "Swaylock Theme" "Error: Theme $chosen not found!"
    fi
    exit 1
fi
