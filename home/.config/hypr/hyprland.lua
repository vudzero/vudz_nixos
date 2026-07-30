-- Hyprland main config (Lua, Hyprland 0.55+)
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "",
    mode     = "highres",
    position = "auto",
    scale    = 2.5,
})

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("HYPRCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("WAYLAND_DISPLAY", "wayland-1")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

---------------------
---- KEYBINDINGS ----
---------------------
require("keybindings")

-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- Services
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd(
        "systemctl --user import-environment XDG_SESSION_TYPE XDG_CURRENT_DESKTOP"
            .. " && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland"
            .. " && systemctl --user start nixos-fake-graphical-session.target"
    )

    -- Applications
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/startup-apps.sh")
end)

-------------------------
---- WORKSPACE NAMES ----
-------------------------
-- Workspaces are not bound to specific monitors
local workspaceNames = {
    [1] = "term",
    [2] = "web",
    [3] = "code",
    [4] = "chat",
    [5] = "media",
    [6] = "misc",
    [7] = "7",
    [8] = "8",
    [9] = "9",
}

for id, name in pairs(workspaceNames) do
    hl.workspace_rule({
        workspace    = tostring(id),
        default_name = name,
    })
end

---------------------------
---- INPUT / CURSOR -------
---------------------------
hl.config({
    input = {
        kb_layout    = "us",
        -- Right Alt as Compose Key; Caps Lock swapped with Escape
        kb_options   = "compose:ralt,caps:swapescape",
        follow_mouse = 1,
        sensitivity  = 0,
    },

    cursor = {
        no_hardware_cursors = 0, -- use hardware cursors when possible
        enable_hyprcursor   = true,
    },
})

-----------------------
---- LOOK AND FEEL ----
-----------------------
require("looknfeel")

----------------------
---- WINDOW RULES ----
----------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Rofi - remove Hyprland borders/padding
hl.window_rule({
    name  = "rofi-no-border",
    match = { class = "Rofi" },
    border_size = 0,
})

-- Nautilus file manager - floating centered window
hl.window_rule({
    name  = "nautilus-float",
    match = { class = "org.gnome.Nautilus" },
    float = true,
    size  = { 1200, 800 },
})

-- Impala terminal - floating pinned window
hl.window_rule({
    name  = "impala-float",
    match = { class = "impala" },
    float = true,
    size  = { 1200, 800 },
    pin   = true,
})

-- Bluetuith terminal - floating pinned window
hl.window_rule({
    name  = "bluetuith-float",
    match = { class = "bluetuith" },
    float = true,
    size  = { 1200, 800 },
    pin   = true,
})

-- Ultra Cinema Player - floating window
hl.window_rule({
    name  = "ultra-cinema-float",
    match = { class = "ultra_cinema" },
    float = true,
})

-- Mal.Game - floating window
hl.window_rule({
    name  = "mal-game-float",
    match = { title = "Mal.Game" },
    float = true,
})

-- Steam games - floating window
hl.window_rule({
    name  = "steam-app-float",
    match = { class = "^steam_app_" },
    float = true,
})

-- MPV video player - floating centered window
hl.window_rule({
    name  = "mpv-float",
    match = { class = "mpv" },
    float  = true,
    size   = { 1200, 800 },
    center = true,
})

-- Evince PDF viewer - floating centered window
hl.window_rule({
    name  = "evince-float",
    match = { class = "org.gnome.Evince" },
    float  = true,
    size   = { 1200, 800 },
    center = true,
})

-- PDF Arranger - floating centered window
hl.window_rule({
    name  = "pdfarranger-float",
    match = { class = "com.github.jeromerobert.pdfarranger" },
    float  = true,
    size   = { 1200, 800 },
    center = true,
})
