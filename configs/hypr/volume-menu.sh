#!/bin/bash
FUZZEL="fuzzel --config $HOME/.config/fuzzel/fuzzel.ini --dmenu --hide-prompt --minimal-lines"

get_volume() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}'
}
is_muted() {
    wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED
}

while true; do
    vol=$(get_volume)
    muted_label="Mute"
    is_muted && muted_label="Unmute"

    entries=" Volume: ${vol}%\n Increase (+5%)\n Decrease (-5%)\n ${muted_label}\n Advanced options\n Exit"
    selected=$(echo -e "$entries" | $FUZZEL --prompt="Audio: " --lines 6 -w 30)

    case "$selected" in
        *Increase*) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;
        *Decrease*) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        *Mute*|*Unmute*) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        *"Advanced options"*) pavucontrol & break ;;
        *Exit*|"") break ;;
        *) break ;;
    esac
done
