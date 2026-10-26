#!/bin/bash
# Toggle del popup de volumen (abrir / cerrar).
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/volume-popup.pid"
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")"
    rm -f "$PIDFILE"
else
    "$HOME/.config/hypr/volume-popup.py" &
    echo $! > "$PIDFILE"
fi
