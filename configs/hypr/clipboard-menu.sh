#!/bin/bash
# Clipboard history picker using cliphist + fuzzel.
selected=$(cliphist list | fuzzel --config ~/.config/fuzzel/fuzzel.ini --dmenu --prompt="Clipboard: " --lines 10 -w 50)
[[ -z "$selected" ]] && exit 0

echo "$selected" | cliphist decode | wl-copy
