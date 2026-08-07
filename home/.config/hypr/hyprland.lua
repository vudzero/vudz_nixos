-- Hyprland main config (Lua, Hyprland 0.55+)
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- DMS-managed outputs (auto-generated at ~/.config/hypr/dms/outputs.lua)
require("dms.outputs")

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- Do NOT set WAYLAND_DISPLAY here — the compositor/UWSM own it.
-- Hardcoding (e.g. wayland-1) breaks DMS/portals when the socket name differs.
hl.env("HYPRCURSOR_SIZE", "32")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
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
-- Session is UWSM-managed: do not start nixos-fake-graphical-session.target
-- or manually import dbus env (UWSM owns graphical-session.target).
-- Launch apps via `uwsm app` so they run in app slices, not inside the
-- compositor unit. https://wiki.hypr.land/Useful-Utilities/Systemd-start/

-- Resolve Chrome profile directory by display name (case-insensitive).
-- Reads ~/.config/google-chrome/Local State via jq.
local function chrome_profile_dir(display_name)
    local state = os.getenv("HOME") .. "/.config/google-chrome/Local State"
    local handle = io.popen(string.format(
        [[jq -r --arg n %q '.profile.info_cache | to_entries[] | select((.value.name | ascii_downcase) == ($n | ascii_downcase)) | .key' %q 2>/dev/null]],
        display_name,
        state
    ))
    if not handle then
        return nil
    end
    local dir = handle:read("*l")
    handle:close()
    if dir and dir ~= "" and dir ~= "null" then
        return dir
    end
    return nil
end

local function shell_quote(s)
    return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

-- Launch in a UWSM app scope (uwsm is always installed via withUWSM).
local function app(cmd)
    return "uwsm app -- " .. cmd
end

local function chrome_cmd(profile_dir, extra_args)
    extra_args = extra_args or ""
    if extra_args ~= "" then
        extra_args = extra_args .. " "
    end
    return "google-chrome-stable " .. extra_args
        .. "--profile-directory=" .. shell_quote(profile_dir)
end

hl.on("hyprland.start", function()
    -- Applications (workspace silent = open there without focusing).
    -- DMS is WantedBy=graphical-session.target and starts via UWSM/systemd.
    hl.exec_cmd(app("alacritty"), { workspace = "1 silent" })
    hl.exec_cmd(app("discord"), { workspace = "2 silent" })
    hl.exec_cmd(app("spotify"), { workspace = "9 silent" })

    -- Chrome: work (Kinova) on 3, personal on 4
    -- Note: launch after DMS if Chrome notifications go to a windowed tray;
    -- Chrome caches "no notification server" at first start for the session.
    local kinova = chrome_profile_dir("kinova")
    if kinova then
        hl.exec_cmd(app(chrome_cmd(kinova)), { workspace = "3 silent" })
    end

    local personal = chrome_profile_dir("personal")
    if personal then
        hl.exec_cmd(app(chrome_cmd(personal)), { workspace = "4 silent" })
    end

    -- Google Chat as a dedicated app window on workspace 2
    hl.exec_cmd(
        app(chrome_cmd("Default", "--app=https://chat.google.com")),
        { workspace = "2 silent" }
    )
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
