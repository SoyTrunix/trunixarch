#!/bin/bash
# ============================================================
# TrunixArch — Instalador de entorno Hyprland + Waybar + Fuzzel
# ============================================================
# Pensado para correr sobre una instalación de Arch Linux limpia
# (con Hyprland ya disponible en los repos). Instala los paquetes
# necesarios y copia la configuración de ventanas (Hyprland),
# barra (Waybar), launcher/menús (fuzzel) y wallpaper (hyprpaper).
#
# Uso:
#   chmod +x install.sh
#   ./install.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/configs"
ASSETS_SRC="$SCRIPT_DIR/assets"

info()  { echo -e "\e[32m[OK]\e[0m $*"; }
warn()  { echo -e "\e[33m[AVISO]\e[0m $*"; }
error() { echo -e "\e[31m[ERROR]\e[0m $*"; }

# ---- Chequeos iniciales ----
if [[ $EUID -eq 0 ]]; then
    error "No corras este script como root. Usá tu usuario normal (va a pedir sudo cuando haga falta)."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    error "Esto está pensado para Arch Linux (o derivadas con pacman). No se encontró pacman."
    exit 1
fi

echo "============================================================"
echo " TrunixArch - Hyprland + Waybar + Fuzzel"
echo "============================================================"
echo "Este script va a:"
echo "  1. Instalar los paquetes necesarios (pacman)."
echo "  2. Copiar la config de Hyprland, Waybar y fuzzel a ~/.config"
echo "  3. Copiar un wallpaper de ejemplo a ~/Pictures/Wallpapers"
echo "  4. Habilitar servicios necesarios (NetworkManager, power-profiles-daemon)"
echo ""
read -rp "¿Continuar? [s/N]: " confirm
[[ "$confirm" =~ ^[sSyY]$ ]] || { echo "Cancelado."; exit 0; }

# ---- Helper para paquetes de AUR (sin depender de paru/yay) ----
aur_install() {
    local pkg="$1"
    if pacman -Qi "$pkg" &>/dev/null; then
        info "$pkg ya instalado."
        return 0
    fi
    local tmp; tmp="$(mktemp -d)"
    git clone --depth 1 "https://aur.archlinux.org/${pkg}.git" "$tmp/$pkg" && \
        (cd "$tmp/$pkg" && makepkg -si --noconfirm --needed) && info "$pkg instalado desde AUR." || warn "No se pudo instalar $pkg desde AUR."
    rm -rf "$tmp"
}

# ---- 1. Paquetes ----
PACKAGES=(
    # Compositor y herramientas base de Hyprland
    hyprland
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    polkit-gnome
    uwsm
    mesa
    base-devel
    git

    # Display manager (pantalla de login gráfica)
    sddm

    # Audio (necesario para wpctl/pavucontrol/playerctl)
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    playerctl

    # Barra, launcher, wallpaper, notificaciones, lock/idle
    waybar
    fuzzel
    hyprpaper
    hyprlock
    hypridle
    mako

    # Terminal y gestor de archivos
    foot
    fish
    starship
    thunar
    thunar-volman
    thunar-archive-plugin
    gvfs

    # Utilidades del sistema usadas por los scripts de la barra/atajos
    grim
    slurp
    wl-clipboard
    cliphist
    fzf
    pavucontrol
    power-profiles-daemon
    brightnessctl
    gsimplecal
    networkmanager
    btop

    # Tema GTK (soporte del cursor/tema por defecto)
    adw-gtk-theme

    # Fuente con íconos (usada en toda la barra y los menús)
    ttf-jetbrains-mono-nerd
)

info "Instalando paquetes con pacman (puede tardar unos minutos)..."
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

info "Instalando tema de cursor/iconos Qogir desde AUR..."
aur_install qogir-icon-theme

# ---- 2. Servicios ----
info "Habilitando servicios del sistema..."
sudo systemctl enable --now NetworkManager.service 2>/dev/null || warn "No se pudo habilitar NetworkManager (¿ya está activo con otro nombre?)"
sudo systemctl enable --now power-profiles-daemon.service 2>/dev/null || warn "No se pudo habilitar power-profiles-daemon"

if systemctl is-enabled sddm.service &>/dev/null || systemctl is-enabled gdm.service &>/dev/null || systemctl is-enabled lightdm.service &>/dev/null; then
    info "Ya hay un display manager habilitado, no toco nada ahí."
else
    sudo systemctl enable sddm.service 2>/dev/null && info "SDDM habilitado como display manager." || warn "No se pudo habilitar SDDM."
fi

# ---- 3. Copiar configuración ----
info "Copiando configuración a ~/.config ..."

mkdir -p "$HOME/.config/hypr" "$HOME/.config/waybar" "$HOME/.config/fuzzel" "$HOME/.config/foot" "$HOME/.config/fish/functions"

# Hyprland (config + scripts usados por binds y por Waybar)
cp -f "$CONFIG_SRC/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
cp -f "$CONFIG_SRC/hypr/"*.sh "$HOME/.config/hypr/"
chmod +x "$HOME/.config/hypr/"*.sh

# hyprpaper.conf: reemplazar el placeholder __HOME__ por la home real del usuario
sed "s|__HOME__|$HOME|g" "$CONFIG_SRC/hypr/hyprpaper.conf" > "$HOME/.config/hypr/hyprpaper.conf"

# Waybar
cp -f "$CONFIG_SRC/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
cp -f "$CONFIG_SRC/waybar/style.css" "$HOME/.config/waybar/style.css"

# fuzzel
cp -f "$CONFIG_SRC/fuzzel/fuzzel.ini" "$HOME/.config/fuzzel/fuzzel.ini"

# foot (terminal)
cp -f "$CONFIG_SRC/foot/foot.ini" "$HOME/.config/foot/foot.ini"

# Cursor por defecto (Qogir-Dark) en GTK, XSETTINGS y X11 (Xresources)
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/xsettingsd"
cp -f "$CONFIG_SRC/gtk/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
cp -f "$CONFIG_SRC/gtk/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
cp -f "$CONFIG_SRC/xsettingsd/xsettingsd.conf" "$HOME/.config/xsettingsd/xsettingsd.conf"
cp -f "$CONFIG_SRC/x11/Xresources" "$HOME/.Xresources"

# starship (prompt)
cp -f "$CONFIG_SRC/starship/starship.toml" "$HOME/.config/starship.toml"

# fish (shell + saludo vacío + invocación de starship)
sed "s|__HOME__|$HOME|g" "$CONFIG_SRC/fish/config.fish" > "$HOME/.config/fish/config.fish"
cp -f "$CONFIG_SRC/fish/functions/fish_greeting.fish" "$HOME/.config/fish/functions/fish_greeting.fish"

# Poner fish como shell por defecto del usuario (si no lo es ya)
FISH_PATH="$(command -v fish)"
if [[ -n "$FISH_PATH" && "$SHELL" != "$FISH_PATH" ]]; then
    grep -qxF "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    chsh -s "$FISH_PATH" "$USER" && info "Shell por defecto cambiado a fish." || warn "No se pudo cambiar el shell a fish, hacelo manualmente con: chsh -s $FISH_PATH"
fi

info "Configuración copiada."

# ---- 4. Wallpaper de ejemplo ----
mkdir -p "$HOME/Pictures/Wallpapers"
if [[ -f "$ASSETS_SRC/wallpaper.png" ]]; then
    cp -n "$ASSETS_SRC/wallpaper.png" "$HOME/Pictures/Wallpapers/wallhaven-8g8q32_1920x1080.png"
    info "Wallpaper de ejemplo copiado a ~/Pictures/Wallpapers/"
else
    warn "No se encontró el wallpaper de ejemplo en $ASSETS_SRC — vas a necesitar poner una imagen vos mismo y ajustar ~/.config/hypr/hyprpaper.conf"
fi

# ---- 5. Avisos finales ----
echo ""
echo "============================================================"
info "Instalación completa."
echo "============================================================"
warn "IMPORTANTE - revisá/ajustá manualmente antes de entrar a la sesión:"
echo "  - ~/.config/hypr/hyprland.conf: las líneas 'monitor =' tienen los nombres"
echo "    de pantalla de la máquina original (eDP-1 / HDMI-A-1). Corré 'hyprctl monitors'"
echo "    después de entrar a Hyprland y ajustá los nombres si no coinciden."
echo "  - Elegí la sesión 'Hyprland' en tu display manager (SDDM u otro) al iniciar sesión."
echo ""
echo "Atajos principales ya configurados:"
echo "  SUPER+T        terminal       SUPER+R   launcher (fuzzel)"
echo "  SUPER+E        explorador     SUPER+Q   cerrar ventana"
echo "  SUPER+B        cambiar wallpaper (preview en vivo)"
echo "  SUPER+C        historial de portapapeles"
echo "  SUPER+N        activar/desactivar notificaciones"
echo "  SUPER+L        bloquear pantalla"
echo ""
