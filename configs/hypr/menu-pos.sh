#!/bin/bash
# Posición de los menús de la derecha (power, batería, red): esquina superior derecha,
# debajo de la barra, con el mismo margen que las notificaciones de mako (10 px).
# Imprime las opciones de fuzzel (output + anclaje).
BAR_GAP=10           # separación vertical bajo la barra (igual que el margen horizontal)
MARGIN=10           # separación con el borde derecho (igual que mako)
read -r cx cy < <(hyprctl cursorpos | tr -d ',')
name=$(hyprctl monitors -j | python3 -c "
import json,sys
cx,cy=$cx,$cy
for m in json.load(sys.stdin):
    if m['x']<=cx<m['x']+m['width'] and m['y']<=cy<m['y']+m['height']:
        print(m['name']); break
else: print('')")
echo "${name:+--output=$name} --anchor=top-right --x-margin=$MARGIN --y-margin=$BAR_GAP"
