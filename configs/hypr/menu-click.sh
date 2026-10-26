#!/bin/bash
# Llamado en cada clic del mouse (bind no consumente). Si hay un menú de la barra
# abierto y el clic fue FUERA de su ventana (y no en la barra), lo cierra.
STATE="${XDG_RUNTIME_DIR:-/tmp}/bar-menu.state"
[[ -f "$STATE" ]] || exit 0
read -r _ID PID < "$STATE"
kill -0 "$PID" 2>/dev/null || { rm -f "$STATE"; exit 0; }
read -r cx cy < <(hyprctl cursorpos | tr -d ',')
(( cy < 34 )) && exit 0                      # clic en la barra: lo maneja bar-menu.sh
PIDS="$PID $(pgrep -x fuzzel | tr '\n' ' ')"
inside=$(hyprctl layers | python3 -c "
import re,sys
cx,cy,pids=$cx,$cy,'$PIDS'.split()
for l in sys.stdin:
    m=re.search(r'xywh: (\d+) (\d+) (\d+) (\d+).*pid: (\d+)',l)
    if m and m.group(5) in pids:
        x,y,w,h=map(int,m.groups()[:4])
        if x<=cx<x+w and y<=cy<y+h: print('yes')
")
[[ "$inside" == "yes" ]] && exit 0
"$HOME/.config/hypr/bar-menu.sh" close
