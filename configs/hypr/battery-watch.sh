#!/bin/bash
# Emite el estado de batería al arrancar y en cada evento de power_supply (enchufar/desenchufar),
# así el icono cambia al instante sin esperar el intervalo de polling.
DIR="$(dirname "$(readlink -f "$0")")"
"$DIR/battery-status.sh"
# Chequeo periódico de batería baja (no depende de eventos udev)
( while sleep 60; do "$DIR/battery-low.sh"; done ) &

udevadm monitor --udev --subsystem-match=power_supply | while read -r _; do
    sleep 1   # dar tiempo a que sysfs actualice status
    "$DIR/battery-status.sh"
done
