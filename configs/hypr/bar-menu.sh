#!/bin/bash
# Gestor de menús de la barra: solo un menú abierto a la vez.
#  - Tocar el icono del menú abierto → lo cierra.
#  - Abrir otro menú → cierra el anterior y abre el nuevo.
# Uso: bar-menu.sh <id> <comando...>
if [[ "$1" == "close" ]]; then
    STATE="${XDG_RUNTIME_DIR:-/tmp}/bar-menu.state"
    [[ -f "$STATE" ]] || exit 0
    read -r _ OLD_PID < "$STATE"; rm -f "$STATE"
    pkill -x fuzzel 2>/dev/null; kill "$OLD_PID" 2>/dev/null
    exit 0
fi
ID="$1"; shift
STATE="${XDG_RUNTIME_DIR:-/tmp}/bar-menu.state"

if [[ -f "$STATE" ]]; then
    read -r OLD_ID OLD_PID < "$STATE"
    rm -f "$STATE"
    if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
        pkill -x fuzzel 2>/dev/null
        kill "$OLD_PID" 2>/dev/null
        [[ "$OLD_ID" == "$ID" ]] && exit 0   # mismo icono: solo cerrar
    fi
fi

"$@" &
echo "$ID $!" > "$STATE"
