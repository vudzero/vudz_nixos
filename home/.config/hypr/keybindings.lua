-- Keybindings
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"

-- Launch terminal / file manager via UWSM app scopes
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("uwsm app -- alacritty"))

-- Launch application launcher (DMS spotlight — IPC to existing service)
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))

-- Launch file manager
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("uwsm app -- nautilus"))

-- Close window
hl.bind(mainMod .. " + Q", hl.dsp.window.close())

-- Toggle floating mode
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))

-- Copy/Paste (universal clipboard shortcuts that work everywhere)
-- Uses Ctrl+c / Ctrl+v via send_shortcut so they work in terminals AND GUI apps
hl.bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "c" }))
hl.bind(mainMod .. " + V", hl.dsp.send_shortcut({ mods = "CTRL", key = "v" }))

-- Reload config (smart reload preserves monitor setup)
hl.bind(
    mainMod .. " + SHIFT + R",
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/smart-reload.sh")
)

-- Lock and suspend
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("dms ipc call lock lock"))

-- Screenshots
hl.bind(
    mainMod .. " + SHIFT + S",
    hl.dsp.exec_cmd(
        'grim -g "$(slurp -w 0)" - | wl-copy && notify-send "Screenshot copied" "Copied to clipboard"'
    )
)
hl.bind(
    "Print",
    hl.dsp.exec_cmd(
        'grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot saved" "Saved to ~/Pictures/"'
    )
)
hl.bind(
    mainMod .. " + SHIFT + E",
    hl.dsp.exec_cmd('grim -g "$(slurp -w 0)" - | swappy -f -')
)

-- Screen recording (10 seconds of selected area)
hl.bind(
    mainMod .. " + SHIFT + V",
    hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/screenrecord.sh")
)

-----------------------------
---- WORKSPACE SWITCHING ----
-----------------------------
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

---------------------------
---- FOCUS & MOVEMENT -----
---------------------------
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Move active workspace to previous / next monitor (Hyprland 0.55+ Lua API)
hl.bind(mainMod .. " + ALT + left",  hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.workspace.move({ monitor = "+1" }))

------------------------
---- VOLUME CONTROLS ----
------------------------
local sound = "/run/current-system/sw/share/sounds/freedesktop/stereo/message.oga"

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && pw-play " .. sound)
)
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && pw-play " .. sound)
)
hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
)

-----------------------
---- MEDIA CONTROLS ----
-----------------------
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

------------------------
---- MOUSE BINDINGS ----
------------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
