#!/bin/bash
# Cambia el volumen (up|down|mute) y muestra un popup con el valor.
# El hint "synchronous" hace que cada aviso reemplace al anterior.
SINK="@DEFAULT_AUDIO_SINK@"

case "$1" in
    up)   wpctl set-volume -l 1 "$SINK" 5%+ ;;
    down) wpctl set-volume "$SINK" 5%- ;;
    mute) wpctl set-mute "$SINK" toggle ;;
esac

info=$(wpctl get-volume "$SINK")
vol=$(echo "$info" | awk '{printf "%d", $2 * 100}')

if echo "$info" | grep -q MUTED; then
    notify-send -t 1200 -h string:x-canonical-private-synchronous:volume "Volume" "Muted"
else
    notify-send -t 1200 -h string:x-canonical-private-synchronous:volume -h int:value:"$vol" "Volume" "${vol}%"
fi
