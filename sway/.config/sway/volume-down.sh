#!/usr/bin/env bash

# Diminui o volume em 5% com limite em 0%
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-

# Obtém o status do mute e volume atual (0 a 100)
IS_MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "\[MUTED\]")
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')

if [ -n "$IS_MUTED" ]; then
    notify-send -h string:x-canonical-private-synchronous:sys-vol \
                -h int:value:0 \
                "Volume" "Muted"
else
    notify-send -h string:x-canonical-private-synchronous:sys-vol \
                -h int:value:"$VOL" \
                "Volume" "${VOL}%"
fi
