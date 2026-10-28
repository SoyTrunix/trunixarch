#!/usr/bin/env python3
# Módulo de workspaces para Waybar: muestra hasta 5 números alrededor del activo.
# El activo va resaltado en celeste. Se actualiza por el socket de eventos de Hyprland.
import json, os, socket, subprocess

MAX = 5

def hypr_json(cmd):
    return json.loads(subprocess.check_output(["hyprctl", cmd, "-j"]))

def render():
    try:
        act = hypr_json("activeworkspace")["id"]
        occ = {w["id"] for w in hypr_json("workspaces")}
    except Exception:
        return
    start = max(1, act - 2)
    cells = []
    for i in range(start, start + MAX):
        if i == act:
            cells.append(f"<span background='#89b4fa' foreground='#1e1e2e' weight='bold'> {i} </span>")
        elif i in occ:
            cells.append(f"<span foreground='#cdd6f4'> {i} </span>")
        else:
            cells.append(f"<span foreground='#6c7086'> {i} </span>")
    print(json.dumps({"text": " ".join(cells), "tooltip": f"Workspace {act}", "class": "ws"}), flush=True)

def main():
    render()
    sig = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
    path = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hypr", sig, ".socket2.sock")
    s = socket.socket(socket.AF_UNIX)
    s.connect(path)
    buf = b""
    while True:
        data = s.recv(4096)
        if not data:
            break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            if line.startswith((b"workspace", b"createworkspace", b"destroyworkspace", b"focusedmon")):
                render()

if __name__ == "__main__":
    main()
