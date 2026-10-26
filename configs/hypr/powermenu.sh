#!/bin/bash
entries=" Shutdown\n Reboot\n Suspend\n Log out"
selected=$(echo -e "$entries" | fuzzel --config ~/.config/fuzzel/fuzzel.ini --dmenu --hide-prompt --minimal-lines --lines 4 -w 16 $(~/.config/hypr/menu-pos.sh))

case "$selected" in
    *Shutdown*) systemctl poweroff ;;
    *Reboot*) systemctl reboot ;;
    *Suspend*) systemctl suspend ;;
    *"Log out"*) hyprctl dispatch 'hl.dsp.exit()' 2>/dev/null | grep -q ok || hyprctl dispatch exit ;;
esac
