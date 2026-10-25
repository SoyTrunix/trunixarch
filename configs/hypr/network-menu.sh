#!/bin/bash
# Wifi connection menu using fuzzel, replacing nmtui.
printf -v LOCK_ICON '\UF023'

FUZZEL="fuzzel --config $HOME/.config/fuzzel/fuzzel.ini --dmenu"

nmcli device wifi rescan 2>/dev/null
sleep 1

# Build list: "SSID  (signal%) [lock icon if secured]"
mapfile -t networks < <(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | awk -F: '!seen[$1]++ && $1 != "" {print}')

menu_items=""
count=0
for net in "${networks[@]}"; do
    ssid=$(echo "$net" | cut -d: -f1)
    signal=$(echo "$net" | cut -d: -f2)
    security=$(echo "$net" | cut -d: -f3)
    icon=""
    [[ "$security" != "--" && -n "$security" ]] && icon="$LOCK_ICON"
    menu_items+="${icon} ${ssid}  (${signal}%)\n"
    count=$((count + 1))
done

selected=$(echo -e "$menu_items" | $FUZZEL --prompt="Network: " --minimal-lines --lines "$count" -w 30)
[[ -z "$selected" ]] && exit 0

# Strip the leading icon (if any) and the trailing "(signal%)" to get the SSID.
ssid=$(echo "$selected" | sed -E "s/^${LOCK_ICON}? *//; s/  \([0-9]+%\)$//")

connect_new() {
    local security
    security=$(nmcli -t -f SSID,SECURITY device wifi list | awk -F: -v s="$ssid" '$1 == s {print $2; exit}')

    if [[ "$security" != "--" && -n "$security" ]]; then
        local password
        password=$(echo "" | $FUZZEL --prompt="Password for $ssid: " --password --minimal-lines --lines 0 -w 30)
        [[ -z "$password" ]] && exit 0
        nmcli device wifi connect "$ssid" password "$password" && notify-send "Network" "Connected to $ssid" || notify-send "Network" "Failed to connect to $ssid"
    else
        nmcli device wifi connect "$ssid" && notify-send "Network" "Connected to $ssid" || notify-send "Network" "Failed to connect to $ssid"
    fi
}

# Already-known connection? Try to activate it first.
if nmcli -t -f NAME connection show | grep -qx "$ssid"; then
    if nmcli connection up "$ssid" &>/dev/null; then
        notify-send "Network" "Connected to $ssid"
        exit 0
    fi
    # Stale/broken saved profile (e.g. wrong or missing password) - drop it and ask again.
    nmcli connection delete "$ssid" &>/dev/null
    connect_new
else
    connect_new
fi
