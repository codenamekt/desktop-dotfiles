#!/usr/bin/env python3
"""Install the session-restore save-on-exit hook into Omarchy's power scripts.

Runs as root (via pkexec). Inserts an idempotent marker-delimited block that
snapshots the session right before logout/reboot/shutdown, so the next login
restores the exact desktop. The save is skipped when the session-restore
plugin is disabled, so disabling the plugin turns the whole feature off.

Re-run anytime (e.g. from the post-update hook after `omarchy update`
restores these system files to defaults).
"""

import os
import re

BLOCK = """\
# BEGIN session-restore save-on-exit
if jq -e '.plugins | any(.id == "session-restore")' "$HOME/.config/omarchy/shell.json" 2>/dev/null; then
  "$HOME/.config/omarchy/plugins/session-restore/hypr-session-restore" save >/dev/null 2>&1 || true
fi
# END session-restore save-on-exit
"""

TARGETS = [
    "/usr/share/omarchy/bin/omarchy-system-logout",
    "/usr/share/omarchy/bin/omarchy-system-reboot",
    "/usr/share/omarchy/bin/omarchy-system-shutdown",
]

BLOCK_RE = re.compile(
    r"# BEGIN session-restore save-on-exit\n.*?# END session-restore save-on-exit\n\n?",
    re.S,
)

changed = []
for target in TARGETS:
    if not os.path.isfile(target):
        continue
    with open(target, encoding="utf-8") as fh:
        content = fh.read()

    content = BLOCK_RE.sub("", content)

    if BLOCK not in content:
        shebang = "#!/bin/bash\n"
        if content.startswith(shebang):
            content = content.replace(shebang, shebang + "\n" + BLOCK, 1)
        else:
            content = BLOCK + "\n" + content
        with open(target, "w", encoding="utf-8") as fh:
            fh.write(content)
        changed.append(target)

if changed:
    print("session-restore power wiring applied to:")
    for target in changed:
        print("  " + target)
else:
    print("session-restore power wiring already present; nothing to do")
