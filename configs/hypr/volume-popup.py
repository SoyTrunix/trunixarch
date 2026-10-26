#!/usr/bin/env python3
# Popup de volumen (slider) anclado debajo del icono de volumen de Waybar.
# Usa gtk-layer-shell para posicionarse, igual que los menús de fuzzel.
# Se cierra con Escape o con un segundo clic en el icono (toggle).
import json
import subprocess

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GtkLayerShell  # noqa: E402

SINK = "@DEFAULT_AUDIO_SINK@"
BAR_HEIGHT = 34
WIDTH = 260

CSS = b"""
window { background-color: rgba(30, 30, 46, 0.95); border-radius: 6px; border: 1px solid #45475a; color: #cdd6f4; }
label { color: #cdd6f4; font-family: "JetBrainsMono Nerd Font"; font-size: 11pt; }
button { background: #313244; color: #cdd6f4; border-radius: 4px; border: none; padding: 4px 8px; }
button:hover { background: rgba(137, 180, 250, 0.25); }
scale trough { background-color: #313244; border-radius: 4px; min-height: 6px; }
scale highlight { background-color: #89b4fa; border-radius: 4px; }
scale slider { background-color: #cdd6f4; border-radius: 50%; min-width: 14px; min-height: 14px; }
"""


def get_volume():
    info = subprocess.run(["wpctl", "get-volume", SINK], capture_output=True, text=True).stdout
    vol = int(round(float(info.split()[1]) * 100)) if info.strip() else 0
    return vol, "MUTED" in info


def set_volume(pct):
    subprocess.run(["wpctl", "set-volume", "-l", "1.5", SINK, f"{pct}%"])


def cursor_xy():
    cx, cy = [int(v) for v in subprocess.run(["hyprctl", "cursorpos"], capture_output=True, text=True)
              .stdout.replace(",", " ").split()]
    return cx, cy


def cursor_left():
    """Margen izquierdo (relativo al monitor): centrado bajo el cursor, dentro de la pantalla."""
    cx, cy = [int(v) for v in subprocess.run(["hyprctl", "cursorpos"], capture_output=True, text=True)
              .stdout.replace(",", " ").split()]
    mons = json.loads(subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True).stdout)
    mx, mw = next(((m["x"], m["width"]) for m in mons
                   if m["x"] <= cx < m["x"] + m["width"] and m["y"] <= cy < m["y"] + m["height"]), (0, 1920))
    left = cx - mx - WIDTH // 2
    return max(6, min(left, mw - WIDTH - 6))


class Popup(Gtk.Window):
    def __init__(self, left):
        super().__init__(title="volume-popup")
        self.set_decorated(False)
        self.set_skip_taskbar_hint(True)
        self.set_default_size(WIDTH, -1)
        self.set_border_width(12)

        # Layer-shell: anclado arriba-izquierda con márgenes calculados al icono.
        # Debe hacerse ANTES de show_all().
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.RIGHT, 10)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 10)
        cx, cy = cursor_xy()
        mon = Gdk.Display.get_default().get_monitor_at_point(cx, cy)
        if mon:
            GtkLayerShell.set_monitor(self, mon)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)

        prov = Gtk.CssProvider()
        prov.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), prov,
                                                 Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        vol, muted = get_volume()
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        self.add(box)

        self.label = Gtk.Label(label=self._text(vol, muted))
        box.pack_start(self.label, False, False, 0)

        self.scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 150, 1)
        self.scale.set_value(vol)
        self.scale.set_draw_value(False)
        self.scale.connect("value-changed", self.on_change)
        box.pack_start(self.scale, False, False, 0)

        mute_btn = Gtk.Button(label="Mute / Unmute")
        mute_btn.connect("clicked", self.on_mute)
        box.pack_start(mute_btn, False, False, 0)

        self.connect("key-press-event", self.on_key)
        self.connect("destroy", Gtk.main_quit)
        self.show_all()

    @staticmethod
    def _text(vol, muted):
        return "Muted" if muted else f"Volume: {vol}%"

    def on_change(self, scale):
        pct = int(scale.get_value())
        set_volume(pct)
        self.label.set_text(self._text(pct, False))

    def on_mute(self, _):
        subprocess.run(["wpctl", "set-mute", SINK, "toggle"])
        vol, muted = get_volume()
        self.label.set_text(self._text(vol, muted))

    def on_key(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()


if __name__ == "__main__":
    Popup(0)
    Gtk.main()
