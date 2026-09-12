-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- DP-1 (3440x1440) is the primary/left monitor
hl.monitor({ output = "DP-1", mode = "3440x1440@60", position = "0x0", scale = 1 })

-- DP-3 (2560x1080) is to the RIGHT of DP-1
hl.monitor({ output = "DP-3", mode = "2560x1080@60", position = "3440x0", scale = 1 })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
