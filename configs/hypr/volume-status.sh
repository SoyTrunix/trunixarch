#!/bin/bash
printf -v ICON_HIGH '\UF028'
printf -v ICON_LOW '\UF027'
printf -v ICON_MUTE '\UF026'

info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol=$(echo "$info" | awk '{printf "%d", $2 * 100}')

if echo "$info" | grep -q MUTED; then
    echo "{\"text\": \"${ICON_MUTE}\", \"tooltip\": \"Muted\", \"class\": \"muted\"}"
elif [[ "$vol" -ge 60 ]]; then
    echo "{\"text\": \"${ICON_HIGH}\", \"tooltip\": \"Volume: ${vol}%\", \"class\": \"high\"}"
elif [[ "$vol" -ge 1 ]]; then
    echo "{\"text\": \"${ICON_LOW}\", \"tooltip\": \"Volume: ${vol}%\", \"class\": \"low\"}"
else
    echo "{\"text\": \"${ICON_MUTE}\", \"tooltip\": \"Volume: 0%\", \"class\": \"muted\"}"
fi
