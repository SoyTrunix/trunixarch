#!/bin/bash
printf -v ICON_MIC '\UF130'

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
    echo "{\"text\": \"${ICON_MIC}\", \"tooltip\": \"Microphone muted\", \"class\": \"muted\"}"
else
    echo "{\"text\": \"${ICON_MIC}\", \"tooltip\": \"Microphone active\", \"class\": \"active\"}"
fi
