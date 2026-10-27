#!/bin/bash
# Gestor de menús de la barra: solo un menú abierto a la vez.
#  - Tocar el icono del menú abierto → lo cierra (instantáneo).
#  - Abrir otro menú → cierra el anterior y abre el nuevo.
#  - Llamadas duplicadas del mismo icono (< 1 s) se descartan.
# Uso: bar-menu.sh <id> <comando...>   |   bar-menu.sh close
RUN="${XDG_RUNTIME_DIR:-/tmp}"
STATE="$RUN/bar-menu.state"
LASTCLOSE="$RUN/bar-menu.lastclose"
POPUP_RE='^python3 .*(calendar|volume)-popup\.py'

exec 9>"$RUN/bar-menu.lock"
flock -w 2 9

close_all() {
    if [[ -f "$STATE" ]]; then read -r _ OLD_PID _ < "$STATE"; kill "$OLD_PID" 2>/dev/null; fi
    rm -f "$STATE"
    pkill -x fuzzel 2>/dev/null
    for p in $(pgrep -f "$POPUP_RE"); do kill "$p" 2>/dev/null; done
}

if [[ "$1" == "close" ]]; then
    close_all
    exit 0
fi

ID="$1"; shift

# Clic que acaba de cerrar un menú (menu-click): este es el mismo icono, no reabrir.
if [[ -f "$LASTCLOSE" ]]; then
    now=$(date +%s%3N); last=$(cat "$LASTCLOSE"); rm -f "$LASTCLOSE"
    (( now - last < 500 )) && exit 0
fi

if [[ -f "$STATE" ]]; then
    read -r OLD_ID OLD_PID _ < "$STATE"
    age=$(( $(date +%s) - $(stat -c %Y "$STATE") ))
    if [[ "$OLD_ID" == "$ID" ]] && (( age < 1 )); then
        exit 0                      # duplicado del mismo clic
    fi
    if [[ "$OLD_ID" == "$ID" ]] && kill -0 "$OLD_PID" 2>/dev/null; then
        close_all                   # mismo icono con menú abierto: cerrar
        exit 0
    fi
fi

close_all                           # cualquier otro menú vivo: cerrar antes de abrir
"$@" 9>&- &
read -r ox _ < <(hyprctl cursorpos | tr -d ",")
echo "$ID $! $ox" > "$STATE"
