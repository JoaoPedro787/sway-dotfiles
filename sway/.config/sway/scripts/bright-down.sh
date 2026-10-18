#!/usr/bin/env bash

# Calcula o valor bruto equivalente a 5% do brilho máximo
MIN_VAL=$(brightnessctl max | awk '{print int($1 * 0.05)}')

# Diminui 5% sem deixar cair abaixo do valor mínimo calculado
brightnessctl set 5%- -n "$MIN_VAL"

# Obtém porcentagem atual
BRIGHTNESS=$(brightnessctl info | awk -F'[(%)]' '/Current brightness/{print $2}')

notify-send -t 1000 \
            -h string:x-canonical-private-synchronous:sys-bright \
            -h int:value:"$BRIGHTNESS" \
            "Brightness" "${BRIGHTNESS}%"
