#!/usr/bin/env bash

# Aumenta 5% do brilho
brightnessctl set +5%

# Obtém porcentagem atual
BRIGHTNESS=$(brightnessctl info | awk -F'[(%)]' '/Current brightness/{print $2}')

notify-send -t 1000 \
            -h string:x-canonical-private-synchronous:sys-bright \
            -h int:value:"$BRIGHTNESS" \
            "Brightness" "${BRIGHTNESS}%"
