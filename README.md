# TrunixArch

**Un escritorio Arch pulido, rápido y listo en minutos.**

Hyprland + Waybar + fuzzel, con una estética coherente de punta a punta: barra, menús, terminal y popups comparten paleta, tipografía y animaciones.

## ✨ Qué tiene

- **Barra elegante** — workspaces, reloj, volumen, micrófono, red, batería y power, todo a un clic.
- **Menús que se sienten nativos** — power, perfiles de energía, red y portapapeles, siempre al alcance del icono.
- **Calendario y volumen en un clic** — popups anclados a la barra, con cierre inteligente.
- **Control total del sistema** — brillo, volumen y multimedia con feedback instantáneo.
- **Wallpapers con preview en vivo** — elegí el fondo mientras lo ves cambiar, y el lockscreen lo sigue.
- **Terminal lista para usar** — foot + fish + starship, con la misma paleta del escritorio.

## 🚀 Instalación en un comando

```bash
git clone https://github.com/SoyTrunix/trunixarch.git
cd TrunixArch
chmod +x install.sh && ./install.sh
```

El script instala los paquetes, copia toda la configuración y te deja listo para iniciar sesión. Solo usa `sudo` para `pacman` y los servicios, y siempre pide confirmación antes de tocar nada.

Después de instalar, elegí la sesión **Hyprland** en el login. Si tus pantallas no se llaman `eDP-1` o `HDMI-A-1`, no hace falta tocar nada: la config detecta y ubica cada monitor sola.

## ⌨️ Atajos

| Atajo | Acción |
|---|---|
| `SUPER + T` | Terminal |
| `SUPER + R` | Launcher de apps |
| `SUPER + E` | Explorador de archivos |
| `SUPER + Q` | Cerrar ventana |
| `SUPER + V` | Flotante / tiling |
| `SUPER + B` | Cambiar wallpaper |
| `SUPER + C` | Historial de portapapeles |
| `SUPER + N` | Activar / desactivar notificaciones |
| `SUPER + L` | Bloquear pantalla |
| `SUPER + 1…0` | Cambiar de workspace |
| `CTRL + SUPER + X` | Mutear / desmutear micrófono |
| `CTRL + SHIFT + ESC` | Abrir btop |
