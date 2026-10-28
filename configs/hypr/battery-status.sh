#!/bin/bash
printf -v ICON_FULL '\UF240'
printf -v ICON_HIGH '\UF241'
printf -v ICON_MED '\UF242'
printf -v ICON_LOW '\UF243'
printf -v ICON_EMPTY '\UF244'

capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || cat /sys/class/power_supply/BAT1/capacity 2>/dev/null)
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || cat /sys/class/power_supply/BAT1/status 2>/dev/null)

if [[ -z "$capacity" ]]; then
    echo "{\"text\": \"\", \"tooltip\": \"No battery\", \"class\": \"none\"}"
    exit 0
fi

if [[ "$capacity" -ge 90 ]]; then icon="$ICON_FULL"
elif [[ "$capacity" -ge 60 ]]; then icon="$ICON_HIGH"
elif [[ "$capacity" -ge 30 ]]; then icon="$ICON_MED"
elif [[ "$capacity" -ge 15 ]]; then icon="$ICON_LOW"
else icon="$ICON_EMPTY"; class="critical"
fi

# Con el adaptador conectado es "cargando" aunque la batería esté "Not charging" (tope/umbral) o "Full"
ac_online=0
for f in /sys/class/power_supply/{AC*,ADP*}/online; do
    [[ -r "$f" && "$(cat "$f")" == "1" ]] && ac_online=1
done

if [[ "$ac_online" == "1" || "$status" == "Charging" || "$status" == "Full" ]]; then
    [[ "$status" == "Full" ]] && state_text="Fully charged (plugged in)" || state_text="Charging"
    [[ "$class" == "critical" ]] || class="charging"
else
    state_text="On battery"
    [[ "$class" == "critical" ]] || class="discharging"
fi

echo "{\"text\": \"${icon}\", \"tooltip\": \"${capacity}% - ${state_text}\", \"class\": \"${class}\"}"
