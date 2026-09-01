#!/usr/bin/env python3
"""Maximize-to-edges the first window opened on an empty workspace.

Subscribes to `niri msg --json event-stream` and, whenever a brand-new
tiled window appears as the only window on its workspace, applies
`maximize-window-to-edges` to it — i.e. new workspaces start in the
Mod+M state by default. The state remains a normal toggle: Mod+M
un-maximizes as usual.

Windows that already exist when the script starts (the initial
WindowsChanged snapshot) are left untouched, so restarting the script
or niri never re-maximizes anything. Floating windows (dialogs etc.)
are ignored both as candidates and when counting workspace occupancy.

Launched from config.kdl via spawn-at-startup; exits when the event
stream closes (i.e. when niri exits).
"""

import json
import subprocess
import sys


def maximize(window_id: int) -> None:
    subprocess.run(
        ["niri", "msg", "action", "maximize-window-to-edges", "--id", str(window_id)],
        check=False,
    )


def main() -> int:
    seen: set[int] = set()  # every window id ever observed this session
    workspace_of: dict[int, int] = {}  # tiled windows only

    proc = subprocess.Popen(
        ["niri", "msg", "--json", "event-stream"],
        stdout=subprocess.PIPE,
        text=True,
    )
    assert proc.stdout is not None

    for line in proc.stdout:
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if "WindowsChanged" in event:
            # Full snapshot: reseed state, never maximize pre-existing windows.
            windows = event["WindowsChanged"]["windows"]
            seen = {w["id"] for w in windows}
            workspace_of = {
                w["id"]: w["workspace_id"]
                for w in windows
                if not w["is_floating"] and w["workspace_id"] is not None
            }

        elif "WindowOpenedOrChanged" in event:
            w = event["WindowOpenedOrChanged"]["window"]
            wid = w["id"]
            ws = w["workspace_id"]
            is_new = wid not in seen
            seen.add(wid)

            if w["is_floating"] or ws is None:
                workspace_of.pop(wid, None)
                continue

            if is_new and ws not in workspace_of.values():
                maximize(wid)
            workspace_of[wid] = ws

        elif "WindowClosed" in event:
            wid = event["WindowClosed"]["id"]
            seen.discard(wid)
            workspace_of.pop(wid, None)

    return proc.wait()


if __name__ == "__main__":
    sys.exit(main())
