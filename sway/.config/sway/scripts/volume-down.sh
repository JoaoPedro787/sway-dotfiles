#!/usr/bin/env bash

# Diminui o volume em 5%
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

# Obtém porcentagem atual
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')

notify-send -t 1000 \
            -h string:x-canonical-private-synchronous:sys-vol \
            -h int:value:"$VOL" \
            "Volume" "${VOL}%"
