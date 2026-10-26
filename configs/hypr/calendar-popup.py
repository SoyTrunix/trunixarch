#!/usr/bin/env python3
# Calendario anclado debajo del reloj de la barra (gtk-layer-shell).
# Botones < y > para cambiar de mes. Se cierra con Escape o con otro clic en el reloj.
import json
import subprocess

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GtkLayerShell  # noqa: E402

BAR_HEIGHT = 34
WIDTH = 240

CSS = b"""
window { background-color: rgba(30, 30, 46, 0.95); border-radius: 6px; border: 1px solid #45475a; color: #cdd6f4; }
calendar { background-color: transparent; color: #cdd6f4; font-family: "JetBrainsMono Nerd Font"; font-size: 11pt; padding: 6px 8px; }
calendar:selected { background-color: #89b4fa; color: #1e1e2e; border-radius: 4px; }
calendar.header { color: #89b4fa; font-weight: bold; }
calendar.highlight { color: #f38ba8; font-weight: bold; }
calendar.other-month { color: #6c7086; }
button { background: #313244; color: #cdd6f4; border-radius: 4px; border: none; padding: 2px 8px; }
button:hover { background: rgba(137, 180, 250, 0.25); }
"""


def cursor_left():
    """Centrado horizontal en el monitor donde está el cursor (siempre arriba al centro)."""
    cx, cy = [int(v) for v in subprocess.run(["hyprctl", "cursorpos"], capture_output=True, text=True)
              .stdout.replace(",", " ").split()]
    mons = json.loads(subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True).stdout)
    mx, mw = next(((m["x"], m["width"]) for m in mons
                   if m["x"] <= cx < m["x"] + m["width"] and m["y"] <= cy < m["y"] + m["height"]), (0, 1920))
    return mx + (mw - WIDTH) // 2 - mx


class Calendar(Gtk.Window):
    def __init__(self, left):
        super().__init__(title="calendar-popup")
        self.set_decorated(False)
        self.set_skip_taskbar_hint(True)
        self.set_size_request(WIDTH, -1)
        self.set_border_width(8)

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        # Solo anclado arriba: layer-shell lo centra horizontalmente en el monitor.
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, BAR_HEIGHT)
        cx, cy = [int(v) for v in subprocess.run(["hyprctl", "cursorpos"], capture_output=True, text=True)
                  .stdout.replace(",", " ").split()]
        mon = Gdk.Display.get_default().get_monitor_at_point(cx, cy)
        if mon:
            GtkLayerShell.set_monitor(self, mon)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)

        prov = Gtk.CssProvider()
        prov.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), prov,
                                                 Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        self.cal = Gtk.Calendar()
        self.cal.set_display_options(Gtk.CalendarDisplayOptions.SHOW_HEADING
                                     | Gtk.CalendarDisplayOptions.SHOW_DAY_NAMES)
        self.add(self.cal)
        self.connect("key-press-event", self.on_key)
        self.show_all()

    def on_key(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()


if __name__ == "__main__":
    Calendar(0)
    Gtk.main()
