#!/usr/bin/env python3
# Calendario anclado arriba al centro del monitor (debajo de la barra), con gtk-layer-shell.
# - Filas solo las necesarias (sin espacio extra abajo).
# - Días de otros meses atenuados.
# - Resaltado "hoy" solo cuando el mes mostrado es el actual.
# - < y > cambian de mes. Se cierra con Escape o con otro clic en el reloj.
import calendar
import datetime
import subprocess

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, Gdk, GtkLayerShell  # noqa: E402

BAR_HEIGHT = 34

CSS = b"""
window { background-color: rgba(30, 30, 46, 0.95); border-radius: 6px; border: 1px solid #45475a; color: #cdd6f4; }
label { color: #cdd6f4; font-family: "JetBrainsMono Nerd Font"; font-size: 10pt; }
.title { color: #89b4fa; font-weight: bold; }
.weekday { color: #f38ba8; font-weight: bold; }
.day { padding: 3px 0; min-width: 28px; }
.other { color: #585b70; }
.weekend { color: #bac2de; }
.today { background-color: #89b4fa; color: #1e1e2e; border-radius: 4px; font-weight: bold; }
button { background: #313244; color: #cdd6f4; border-radius: 4px; border: none; padding: 2px 8px; min-height: 0; }
button:hover { background: rgba(137, 180, 250, 0.25); }
"""


def cursor_monitor():
    cx, cy = [int(v) for v in subprocess.run(["hyprctl", "cursorpos"], capture_output=True, text=True)
              .stdout.replace(",", " ").split()]
    return Gdk.Display.get_default().get_monitor_at_point(cx, cy)


class Calendar(Gtk.Window):
    def __init__(self):
        super().__init__(title="calendar-popup")
        self.set_decorated(False)
        self.set_skip_taskbar_hint(True)
        self.set_border_width(10)

        today = datetime.date.today()
        self.today = today
        self.year, self.month = today.year, today.month

        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)   # sin L/R: se centra solo
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 10)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.ON_DEMAND)
        mon = cursor_monitor()
        if mon:
            GtkLayerShell.set_monitor(self, mon)

        prov = Gtk.CssProvider()
        prov.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(Gdk.Screen.get_default(), prov,
                                                 Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

        self.box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(self.box)

        header = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.box.pack_start(header, False, False, 0)
        prev_btn = Gtk.Button(label="<")
        prev_btn.connect("clicked", lambda *_: self.shift(-1))
        next_btn = Gtk.Button(label=">")
        next_btn.connect("clicked", lambda *_: self.shift(1))
        self.title = Gtk.Label()
        self.title.get_style_context().add_class("title")
        header.pack_start(prev_btn, False, False, 0)
        header.pack_start(self.title, True, True, 0)
        header.pack_start(next_btn, False, False, 0)

        self.grid = Gtk.Grid(column_homogeneous=True, row_spacing=3, column_spacing=4)
        self.box.pack_start(self.grid, False, False, 0)

        self.connect("key-press-event", self.on_key)
        self.render()
        self.show_all()

    def shift(self, delta):
        m = self.month + delta
        self.year += (m - 1) // 12
        self.month = (m - 1) % 12 + 1
        self.render()

    def render(self):
        for child in self.grid.get_children():
            self.grid.remove(child)
        self.title.set_text(f"{calendar.month_name[self.month]} {self.year}")

        for col, name in enumerate(["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]):
            lbl = Gtk.Label(label=name)
            lbl.get_style_context().add_class("weekday")
            self.grid.attach(lbl, col, 0, 1, 1)

        weeks = calendar.Calendar(firstweekday=6).monthdatescalendar(self.year, self.month)
        for row, week in enumerate(weeks, start=1):
            for col, day in enumerate(week):
                lbl = Gtk.Label(label=str(day.day))
                ctx = lbl.get_style_context()
                ctx.add_class("day")
                if day.month != self.month:
                    ctx.add_class("other")
                elif day == self.today:
                    ctx.add_class("today")
                elif col in (0, 6):
                    ctx.add_class("weekend")
                self.grid.attach(lbl, col, row, 1, 1)
        self.grid.show_all()
        self.resize(1, 1)

    def on_key(self, _, event):
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()


if __name__ == "__main__":
    Calendar()
    Gtk.main()
