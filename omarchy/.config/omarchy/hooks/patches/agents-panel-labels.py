#!/usr/bin/env python3
"""Apply Omarchy agents-panel button-label overrides.

Idempotent. Patches /usr/share/omarchy/shell/plugins/agents/Panel.qml so
that provider buttons that overflow their cell width can be relabeled
without changing the collector or the panel hero title.

Run manually:    sudo python3 agents-panel-labels.py
Run on update:   ~/.config/omarchy/hooks/post-update.d/55-patch-agents-panel
"""
from __future__ import annotations

import pathlib
import sys

PATH = pathlib.Path("/usr/share/omarchy/shell/plugins/agents/Panel.qml")

# Anchor on the original upstream line. If omarchy changes this exact text,
# the patch needs updating — fail loudly so a human notices.
OLD_LINE = "                text: modelData.providerName\n"
NEW_BLOCK = """\
                // Button labels that don't fit the cell width.
                // Hero titles and other UI surfaces keep the full provider name.
                readonly property var labelOverrides: ({
                  "OpenRouter": "OpRoute"
                })
                text: labelOverrides[modelData.providerName]
                  || modelData.providerName.replace(/ Code$/, "")
"""

# If this token appears anywhere in the file, our block is already installed.
MARKER = "labelOverrides:"


def main() -> int:
    if not PATH.exists():
        print(f"agents-panel-labels: {PATH} not found — skipping", file=sys.stderr)
        return 0
    try:
        text = PATH.read_text()
    except PermissionError:
        print(f"agents-panel-labels: cannot read {PATH}; re-run with sudo", file=sys.stderr)
        return 1

    if MARKER in text:
        print("agents-panel-labels: already applied")
        return 0

    if OLD_LINE not in text:
        print(
            f"agents-panel-labels: anchor line not found in {PATH}.\n"
            f"Omarchy may have changed Panel.qml — review and update the patch.",
            file=sys.stderr,
        )
        return 0  # don't break omarchy update; flag for human attention

    text = text.replace(OLD_LINE, NEW_BLOCK, 1)
    try:
        PATH.write_text(text)
    except PermissionError:
        print(f"agents-panel-labels: cannot write {PATH}; re-run with sudo", file=sys.stderr)
        return 1

    print("agents-panel-labels: applied")
    return 0


if __name__ == "__main__":
    sys.exit(main())
