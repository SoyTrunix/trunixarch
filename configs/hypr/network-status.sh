#!/bin/bash
printf -v ICON_CABLE '\UF108'
printf -v ICON_WIFI '\UF1EB'
printf -v ICON_WARN '\UF071'

ethernet=$(nmcli -t -f TYPE,STATE device | grep "^ethernet:connected")
wifi_line=$(nmcli -t -f ACTIVE,SSID,SIGNAL device wifi list | grep "^yes:")

if [[ -n "$ethernet" ]]; then
    echo "{\"text\": \"${ICON_CABLE}\", \"tooltip\": \"Connected via Ethernet\", \"class\": \"connected\"}"
elif [[ -n "$wifi_line" ]]; then
    ssid=$(echo "$wifi_line" | cut -d: -f2)
    signal=$(echo "$wifi_line" | cut -d: -f3)
    echo "{\"text\": \"${ICON_WIFI}\", \"tooltip\": \"Connected to ${ssid} (${signal}%)\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"${ICON_WARN}\", \"tooltip\": \"No network - click to connect\", \"class\": \"disconnected\"}"
fi
