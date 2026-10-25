# TrunixArch

Instalador de mi entorno de escritorio para Arch Linux: **Hyprland + Waybar + fuzzel + hyprpaper**.

Pensado para correr sobre una instalación de Arch Linux limpia y dejar el entorno funcionando tal cual, sin necesidad de armar todo a mano de nuevo.

## Qué instala y configura

- **Hyprland** (compositor, config de ventanas flotantes estilo escritorio tradicional, atajos de teclado).
- **Waybar** (barra superior: workspaces, reloj, tray, micrófono, volumen, red, batería, botón de power).
- **fuzzel** (launcher de apps y todos los menús: power, perfiles de batería, red, portapapeles).
- **hyprpaper** (wallpaper, con selector visual con preview en vivo vía `SUPER+B`).
- **fish + starship** (shell por defecto con prompt minimalista `~ ❯`).
- Resto de utilidades: `mako` (notificaciones), `hypridle`/`hyprlock` (bloqueo/suspensión), Thunar, `cliphist`, `grim`/`slurp`, `pavucontrol`, `power-profiles-daemon`, `playerctl`, `btop`.

## Uso

```bash
git clone <este-repo>
cd TrunixArch
chmod +x install.sh
./install.sh
```

El script pide confirmación antes de instalar nada y usa `sudo` solo para `pacman` y para habilitar servicios.

## Después de instalar

1. Corré `hyprctl monitors` dentro de una sesión de Hyprland y ajustá las líneas `monitor =` en `~/.config/hypr/hyprland.conf` si tus pantallas no se llaman `eDP-1`/`HDMI-A-1`.
2. Elegí la sesión **Hyprland** en la pantalla de login (SDDM u otro display manager).

## Atajos principales

| Atajo | Acción |
|---|---|
| `SUPER + T` | Terminal |
| `SUPER + R` | Launcher de apps |
| `SUPER + E` | Explorador de archivos |
| `SUPER + Q` | Cerrar ventana |
| `SUPER + V` | Alternar flotante/tiling |
| `SUPER + B` | Cambiar wallpaper (preview en vivo) |
| `SUPER + C` | Historial de portapapeles |
| `SUPER + N` | Activar/desactivar notificaciones |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + 1-0` | Cambiar de workspace |
| `CTRL + SUPER + X` | Mutear/desmutear micrófono |
| `CTRL + SHIFT + ESC` | Abrir btop |
