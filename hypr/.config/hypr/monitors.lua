-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Big ultrawide on the left
hl.monitor({ output = "DP-1", mode = "3440x1440@60", position = "0x0", scale = omarchy_monitor_scale })

-- Smaller ultrawide to the right of DP-1
hl.monitor({ output = "DP-3", mode = "2560x1080@60", position = "auto-right", scale = omarchy_monitor_scale })
