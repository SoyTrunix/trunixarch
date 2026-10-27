#!/bin/bash
# Llamado en cada clic del mouse (bind no consumente).
#  - Clic FUERA de un menú de la barra → lo cierra.
#  - Clic EN la barra con un menú abierto → lo cierra, para que Waybar reciba el clic
#    y abra el menú del icono tocado (bar-menu.sh).
# Considera también los popups (calendario, volumen) aunque se haya perdido el archivo de estado.
STATE="${XDG_RUNTIME_DIR:-/tmp}/bar-menu.state"
LASTCLOSE="${XDG_RUNTIME_DIR:-/tmp}/bar-menu.lastclose"
POPUP_RE='^python3 .*(calendar|volume)-popup\.py'

pids=""
if [[ -f "$STATE" ]]; then
    read -r _ID PID OLDX < "$STATE"
    kill -0 "$PID" 2>/dev/null && pids="$PID"
fi
pids="$pids $(pgrep -x fuzzel | tr '\n' ' ') $(pgrep -f "$POPUP_RE" | tr '\n' ' ')"
pids=$(echo $pids)
[[ -z "$pids" ]] && { rm -f "$STATE"; exit 0; }



read -r cx cy < <(hyprctl cursorpos | tr -d ',')
close_all() {
    pkill -x fuzzel 2>/dev/null
    for p in $pids; do kill "$p" 2>/dev/null; done
    rm -f "$STATE"
}
if (( cy < 34 )); then
    # Solo en la barra: si el menú se acaba de abrir con este clic, no tocarlo.
    if [[ -f "$STATE" ]] && (( $(date +%s) - $(stat -c %Y "$STATE") < 1 )); then exit 0; fi
    for p in $pids; do
        age=$(ps -o etimes= -p "$p" 2>/dev/null | tr -d ' ')
        [[ -n "$age" ]] && (( age < 2 )) && exit 0
    done
    close_all
    date +%s%3N > "$LASTCLOSE"
    # Si el clic fue en OTRO icono, repetirlo cuando el menú ya no tiene el foco,
    # para que Waybar abra el menú de ese icono. Mismo icono → solo cierra.
    if [[ -z "$OLDX" ]] || (( cx < OLDX - 60 || cx > OLDX + 60 )); then
        ( sleep 0.6 && ydotool click 0xC0 >/dev/null 2>&1 ) &
    fi
    exit 0
fi

inside=$(hyprctl layers | python3 -c "
import re,sys
cx,cy,pids=$cx,$cy,'$pids'.split()
for l in sys.stdin:
    m=re.search(r'xywh: (\d+) (\d+) (\d+) (\d+).*pid: (\d+)',l)
    if m and m.group(5) in pids:
        x,y,w,h=map(int,m.groups()[:4])
        if x<=cx<x+w and y<=cy<y+h: print('yes')
")
[[ "$inside" == "yes" ]] && exit 0
close_all
