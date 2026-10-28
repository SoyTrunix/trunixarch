#!/bin/bash
# Muestra campana roja solo cuando las notificaciones (mako dnd) están desactivadas.
printf -v ICON_BELL '\UF0F3'   # nf-fa-bell
if makoctl mode 2>/dev/null | grep -q dnd; then
    echo "{\"text\": \"${ICON_BELL}\", \"tooltip\": \"Notifications disabled\", \"class\": \"dnd\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"Notifications enabled\", \"class\": \"enabled\"}"
fi
