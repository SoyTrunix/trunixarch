#!/bin/bash
# Live-preview wallpaper switcher using fzf (updates the desktop as you move
# between options, confirms on Enter, restores the previous one on Esc).
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

apply_wallpaper() {
    local path="$1"
    for monitor in $(hyprctl monitors -j | python3 -c "import json,sys; print('\n'.join(m['name'] for m in json.load(sys.stdin)))"); do
        hyprctl hyprpaper wallpaper "$monitor,$path" &> /dev/null
    done
}

# Internal mode: just apply one wallpaper and exit (used by fzf's focus hook).
if [[ "$1" == "--apply-only" ]]; then
    apply_wallpaper "$2"
    exit 0
fi

# Remember current wallpaper so we can restore it if the user cancels (Esc).
current_line=$(hyprctl hyprpaper listloaded 2>/dev/null | head -1)

selected=$(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort |
    fzf --height=100% --layout=reverse --border --prompt="Wallpaper> " \
        --preview-window=hidden \
        --bind "focus:execute-silent(\"$HOME/.config/hypr/wallpaper-menu.sh\" --apply-only {})"
)

if [[ -n "$selected" ]]; then
    apply_wallpaper "$selected"
    # También actualizar el fondo del lockscreen (hyprlock) para que coincida.
    sed -i "s|^    path = .*|    path = ${selected}|" "$HOME/.config/hypr/hyprlock.conf"
    notify-send "Wallpaper" "Changed to $(basename "$selected")"
elif [[ -n "$current_line" ]]; then
    apply_wallpaper "$current_line"
fi
