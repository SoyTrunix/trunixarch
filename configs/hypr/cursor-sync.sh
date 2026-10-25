#!/bin/bash
# Sincroniza el tema de cursor elegido en nwg-look con todas las capas:
# GTK (gsettings), XSETTINGS (XWayland), Xresources (X11) y Hyprland.

GTK3="$HOME/.config/gtk-3.0/settings.ini"
GTK4="$HOME/.config/gtk-4.0/settings.ini"

theme=$(grep -m1 '^gtk-cursor-theme-name=' "$GTK3" | cut -d= -f2)
size=$(grep -m1 '^gtk-cursor-theme-size=' "$GTK3" | cut -d= -f2)
[[ -z "$theme" ]] && exit 0
size=${size:-24}

# GTK / gsettings
gsettings set org.gnome.desktop.interface cursor-theme "$theme"
gsettings set org.gnome.desktop.interface cursor-size "$size"

# GTK4 settings file (por si nwg-look no lo escribió)
sed -i "s|^gtk-cursor-theme-name=.*|gtk-cursor-theme-name=$theme|" "$GTK4" 2>/dev/null

# XSETTINGS (apps XWayland / Chromium / Spotify)
sed -i "s|^Gtk/CursorThemeName .*|Gtk/CursorThemeName \"$theme\"|" "$HOME/.config/xsettingsd/xsettingsd.conf"
pkill -HUP xsettingsd 2>/dev/null || { pkill xsettingsd; xsettingsd -c "$HOME/.config/xsettingsd/xsettingsd.conf" & }

# X11 resources (Steam, juegos XWayland)
sed -i "s|^Xcursor.theme:.*|Xcursor.theme: $theme|; s|^Xcursor.size:.*|Xcursor.size: $size|" "$HOME/.Xresources"
xrdb -merge "$HOME/.Xresources" 2>/dev/null

# Hyprland: cursor en vivo y variable de entorno de la sesión
hyprctl setcursor "$theme" "$size" >/dev/null
hyprctl keyword env "XCURSOR_THEME,$theme" >/dev/null
hyprctl keyword env "XCURSOR_SIZE,$size" >/dev/null
