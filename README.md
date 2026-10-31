# TrunixArch Config

**Un escritorio Arch Minimalista**

## Instalación en un comando

```bash
git clone https://github.com/SoyTrunix/trunixarch.git
cd TrunixArch
chmod +x install.sh && ./install.sh
```

El script instala los paquetes, copia toda la configuración de este repositorio.

Después de instalar, elegí la sesión **Hyprland** en el login. Si tus pantallas no se llaman `eDP-1` o `HDMI-A-1`, no hace falta tocar nada: la config detecta y ubica cada monitor sola.

## 🖥️ Pantalla de login

El instalador deja configurado **Trunix Hyprlock**, un tema de SDDM con el mismo estilo visual que el lockscreen de Hyprland (paleta Catppuccin Mocha, tu wallpaper de fondo con blur) e incluye selector de sesión, usuario y contraseña.

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
| `SUPER + 1…9` | Cambiar de workspace |
| `SUPER + SHIFT + 1…9` | Mover ventana a otro workspace |
| `CTRL + SUPER + X` | Mutear / desmutear micrófono |
| `CTRL + SHIFT + ESC` | Abrir btop |
