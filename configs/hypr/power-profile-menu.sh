#!/bin/bash
current=$(powerprofilesctl get)

entries="Balanced\nMax Performance\nBattery Saver"
selected=$(echo -e "$entries" | fuzzel --config ~/.config/fuzzel/fuzzel.ini --dmenu --hide-prompt --minimal-lines --lines 3 -w 26)

case "$selected" in
    "Balanced") powerprofilesctl set balanced ;;
    "Max Performance") powerprofilesctl set performance ;;
    "Battery Saver") powerprofilesctl set power-saver ;;
esac

[[ -n "$selected" ]] && notify-send "Power profile" "Set to $selected (was: $current)"
