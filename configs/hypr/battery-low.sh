#!/bin/bash
# Notificación crítica una sola vez al bajar de 10 % en batería; se rearma al cargar o pasar de 15 %.
FLAG="${XDG_RUNTIME_DIR:-/tmp}/battery-low-notified"
BAT=/sys/class/power_supply/BAT0
[[ -d $BAT ]] || BAT=/sys/class/power_supply/BAT1
[[ -d $BAT ]] || exit 0

capacity=$(cat "$BAT/capacity" 2>/dev/null) || exit 0
status=$(cat "$BAT/status" 2>/dev/null)

if [[ "$status" == "Discharging" ]] && (( capacity <= 10 )); then
    if [[ ! -f $FLAG ]]; then
        notify-send -u critical -i battery-caution "Batería baja" "Quedan ${capacity}%. Conectá el cargador."
        touch "$FLAG"
    fi
elif [[ "$status" != "Discharging" ]] || (( capacity > 15 )); then
    rm -f "$FLAG"
fi
