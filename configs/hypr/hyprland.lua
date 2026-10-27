-- ============================================================
-- Hyprland (Lua) - equivalente a ~/.config/hypr/hyprland.conf
-- Entorno de prueba: NO reemplaza el entorno actual.
-- Los scripts y configs auxiliares siguen en ~/.config/hypr
-- (waybar, fuzzel, hyprlock, hypridle, hyprpaper, mako, cursor).
-- ============================================================

local home = os.getenv("HOME")

-- ---- Variables (las mismas que en el .conf) ----
local terminal   = "foot"
local fileMgr    = "thunar"
local menu       = "fuzzel --config " .. home .. "/.config/fuzzel/fuzzel.ini"
local hyprDir    = home .. "/.config/hypr"

local mainMod    = "SUPER"

-- Flags de bind
local locked           = { locked = true }
local mouse            = { mouse = true }
local locked_repeating = { locked = true, repeating = true }

-- ---- Monitores ----
-- Regla genérica para cualquier monitor: máxima tasa de refresco ("highrr") y
-- ubicación automática (uno al lado del otro). No depende de nombres ni resoluciones.
hl.monitor({ output = "", mode = "highrr", position = "auto", scale = 1 })

-- ---- Variables de entorno ----
hl.env("XCURSOR_THEME", "Qogir-Dark")
hl.env("XCURSOR_SIZE", "18")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("GTK_THEME", "adw-gtk3-dark")
hl.env("QT_STYLE_OVERRIDE", "Fusion")

-- ---- Autostart ----
hl.on("hyprland.start", function()
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
    hl.exec_cmd("xrdb -merge " .. home .. "/.Xresources")
    hl.exec_cmd("xsettingsd -c " .. home .. "/.config/xsettingsd/xsettingsd.conf")
    hl.exec_cmd(hyprDir .. "/cursor-sync.sh")
    hl.exec_cmd(hyprDir .. "/cursor-watch.sh")
    hl.exec_cmd("waybar -c " .. home .. "/.config/waybar/config.jsonc -s " .. home .. "/.config/waybar/style.css")
    hl.exec_cmd("mako -c " .. hyprDir .. "/mako.ini")
    hl.exec_cmd("sleep 1 && hyprpaper -c " .. hyprDir .. "/hyprpaper.conf")
    hl.exec_cmd("hypridle --config " .. hyprDir .. "/hypridle.conf")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-- ---- Input ----
hl.config({
    input = {
        kb_layout    = "latam",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad     = { natural_scroll = true },
    },
})

-- ---- General / layout ----
hl.config({
    general = {
        gaps_in     = 2,
        gaps_out    = 2,
        border_size = 1,
        layout      = "dwindle",
        col = {
            active_border   = "rgba(6c7086ff)",
            inactive_border = "rgba(3a3a3aaa)",
        },
    },
    dwindle = {
        preserve_split = true,
    },
    gestures = {
        workspace_swipe_distance = 700,
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- ---- Decoración ----
hl.config({
    decoration = {
        rounding = 5,
        blur = {
            enabled = true,
            size    = 8,
            passes  = 2,
        },
        shadow = {
            enabled = false,
        },
    },
})

-- ---- Animaciones ----
hl.config({ animations = { enabled = true } })
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })

-- ---- Reglas de ventana ----
-- Ventanas siempre flotantes (estilo KDE)
hl.window_rule({ match = { class = ".*" }, float = true })

-- Selector de wallpapers: flotante, centrado, tamaño fijo
hl.window_rule({ match = { title = "wallpaper-switcher" }, float = true, center = true, size = "700 500" })

-- ---- Atajos: aplicaciones ----
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd('foot -T "btop" btop'))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileMgr))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock --config " .. hyprDir .. "/hyprlock.conf"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd('foot -T "wallpaper-switcher" -W 60x20 ' .. hyprDir .. "/wallpaper-menu.sh"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(hyprDir .. "/clipboard-menu.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(
    'makoctl mode -t dnd && notify-send "Notifications" "$(makoctl mode | grep -q dnd && echo Disabled || echo Enabled)"'))

-- ---- Atajos: ventanas ----
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Mover foco
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
end

-- Workspaces 1-10 (y mover ventana al workspace)
for i = 1, 10 do
    local key = (i == 10) and "0" or tostring(i)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Mouse: mover y redimensionar ventanas flotantes
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), mouse)
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), mouse)
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), mouse)

-- Clic fuera de un menú de la barra: lo cierra (no consume el clic).
local nonConsuming = { non_consuming = true }
hl.bind("mouse:272", hl.dsp.exec_cmd(hyprDir .. "/menu-click.sh"), nonConsuming)
hl.bind("mouse:273", hl.dsp.exec_cmd(hyprDir .. "/menu-click.sh"), nonConsuming)

-- ---- Capturas ----
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- ---- Audio / brillo / multimedia ----
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(hyprDir .. "/volume-osd.sh up"), locked_repeating)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(hyprDir .. "/volume-osd.sh down"), locked_repeating)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(hyprDir .. "/volume-osd.sh mute"), locked_repeating)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && pkill -RTMIN+8 waybar"), locked_repeating)
hl.bind("CTRL + " .. mainMod .. " + X", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && pkill -RTMIN+8 waybar"))
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(hyprDir .. "/brightness-osd.sh up"), locked_repeating)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(hyprDir .. "/brightness-osd.sh down"), locked_repeating)
