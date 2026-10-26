#!/bin/bash
# Cambia el brillo (up|down) y muestra un popup con el porcentaje.
# El hint "synchronous" hace que cada aviso reemplace al anterior.
command -v brightnessctl >/dev/null || exit 1

case "$1" in
    up)   brightnessctl set 5%+ -q ;;
    down) brightnessctl set 5%- -q ;;
esac

cur=$(brightnessctl get)
max=$(brightnessctl max)
pct=$(( cur * 100 / max ))

notify-send -t 1200 -h string:x-canonical-private-synchronous:brightness -h int:value:"$pct" "Brightness" "${pct}%"
