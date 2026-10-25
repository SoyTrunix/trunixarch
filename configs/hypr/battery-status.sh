#!/bin/bash
printf -v ICON_FULL '\UF240'
printf -v ICON_HIGH '\UF241'
printf -v ICON_MED '\UF242'
printf -v ICON_LOW '\UF243'
printf -v ICON_EMPTY '\UF244'
printf -v ICON_CHARGING '\UF1E6'

capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null)

if [[ -z "$capacity" ]]; then
    echo "{\"text\": \"\", \"tooltip\": \"No battery\", \"class\": \"none\"}"
    exit 0
fi

if [[ "$status" == "Charging" ]]; then
    icon="$ICON_CHARGING"
    state_text="Charging"
    class="charging"
elif [[ "$status" == "Full" ]]; then
    icon="$ICON_FULL"
    state_text="Fully charged (plugged in)"
    class="charging"
else
    state_text="On battery"
    class="discharging"
    if [[ "$capacity" -ge 90 ]]; then icon="$ICON_FULL"
    elif [[ "$capacity" -ge 60 ]]; then icon="$ICON_HIGH"
    elif [[ "$capacity" -ge 30 ]]; then icon="$ICON_MED"
    elif [[ "$capacity" -ge 15 ]]; then icon="$ICON_LOW"
    else icon="$ICON_EMPTY"; class="critical"
    fi
fi

echo "{\"text\": \"${icon}\", \"tooltip\": \"${capacity}% - ${state_text}\", \"class\": \"${class}\"}"
