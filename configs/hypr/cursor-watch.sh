#!/bin/bash
# Vigila el tema de cursor en settings.ini de GTK (donde nwg-look lo guarda)
# y re-aplica en todas las capas cuando el valor cambia.

GTK3="$HOME/.config/gtk-3.0/settings.ini"
SYNC="$HOME/.config/hypr/cursor-sync.sh"

current() { grep -m1 '^gtk-cursor-theme-name=' "$GTK3" 2>/dev/null; }

last=$(current)
while sleep 5; do
    now=$(current)
    if [[ "$now" != "$last" ]]; then
        last="$now"
        "$SYNC"
    fi
done
