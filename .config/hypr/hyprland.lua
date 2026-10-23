------------------
---- MONITORS ----
------------------
hl.monitor({
    output     = "",
    mode       = "preferred",
    position = "auto",
    scale    = "auto",
})

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "qs ipc call menu toggle apps"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function ()
hl.exec_cmd("hyprpaper")
hl.exec_cmd("qs")
hl.exec_cmd("wl-paste --type text --watch cliphist store")
hl.exec_cmd("wl-paste --type image --watch cliphist store")
hl.exec_cmd("hypridle")
hl.exec_cmd("kitty --class btop-win -o background_opacity=0.65 -e btop")
hl.exec_cmd("sleep 0.8 && kitty --class fetch-win -o background_opacity=0.65 -e sh -c 'fastfetch; exec sleep infinity'")
hl.exec_cmd("sleep 1.6 && kitty --class matrix-win -o background_opacity=0.65 -e cmatrix -b -C white")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")

-----------------------
---- LOOK AND FEEL ----
-----------------------
local ok, c = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/colors.lua")
if not ok then
    c = { active = "rgba(ffffffee)", active2 = "rgba(7a7a7aee)", inactive = "rgba(40404066)" }
    end

    hl.config({
        general = {
            gaps_in  = 4,
            gaps_out = 8,
            border_size = 2,
            col = {
                active_border   = { colors = { c.active, c.active2, c.active }, angle = 45 },
                inactive_border = c.inactive,
            },
            resize_on_border = true,
            allow_tearing = false,
            layout = "dwindle",
        },

        decoration = {
            rounding             = 12,
            rounding_power       = 2,
            active_opacity       = 1.0,
            inactive_opacity     = 0.9,

            shadow = {
                enabled      = true,
                range        = 20,
                render_power = 3,
                color        = "rgba(00000066)",
            },

            -- High-performance deep blur
            blur = {
                enabled           = true,
                size              = 12,
                passes            = 4,
                noise             = 0.02,
                contrast          = 0.9,
                brightness        = 0.8,
                vibrancy          = 0.3,
                vibrancy_darkness = 0.3,
                popups            = true,
                special           = true,
                new_optimizations = true,
                ignore_opacity    = true,
                xray              = false,
            },
        },

        animations = {
            enabled = true,
        },

        dwindle = {
            preserve_split = true,
        },

        misc = {
            force_default_wallpaper  = 0,
                disable_hyprland_logo    = true,
                disable_splash_rendering = true,
        },
    })

    -- Curves
    hl.curve("expo",     { type = "bezier", points = { {0.16, 1}, {0.3, 1}  } })
    hl.curve("silkFade", { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })
    hl.curve("linear",   { type = "bezier", points = { {0, 0},    {1, 1}    } })

    -- Springs
    hl.curve("silk",  { type = "spring", mass = 1, stiffness = 120, dampening = 22 })
    hl.curve("float", { type = "spring", mass = 1, stiffness = 80,  dampening = 18 })

    -- Animations
    hl.animation({ leaf = "windows",         enabled = true, speed = 6,  spring = "silk" })
    hl.animation({ leaf = "windowsIn",       enabled = true, speed = 6,  spring = "float",  style = "popin 70%" })
    hl.animation({ leaf = "windowsOut",      enabled = true, speed = 5,  bezier = "expo",   style = "popin 70%" })
    hl.animation({ leaf = "windowsMove",     enabled = true, speed = 6,  spring = "silk" })
    hl.animation({ leaf = "fade",            enabled = true, speed = 6,  bezier = "silkFade" })
    hl.animation({ leaf = "fadeLayers",      enabled = true, speed = 6,  bezier = "silkFade" })
    hl.animation({ leaf = "layers",          enabled = true, speed = 6,  bezier = "expo",   style = "fade" })
    hl.animation({ leaf = "border",          enabled = true, speed = 12, bezier = "expo" })
    hl.animation({ leaf = "borderangle",     enabled = true, speed = 60, bezier = "linear", style = "loop" })
    hl.animation({ leaf = "workspaces",      enabled = true, speed = 7,  spring = "silk",   style = "slide" })
    hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6,  spring = "silk",   style = "slidevert" })

    -- Layer & Blur Rules
    hl.layer_rule({
        name  = "qs-blur",
        match = { namespace = "qs-.*" },
        blur  = true,
        ignore_alpha = 0.3,
    })

    ---------------
    ---- INPUT ----
    ---------------
    hl.config({
        input = {
            kb_layout    = "us",
            follow_mouse = 1,
            sensitivity  = 0,
            touchpad = {
                natural_scroll = false,
            },
        },
    })

    hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace",
    })

    ---------------------
    ---- KEYBINDINGS ----
    ---------------------
    local mainMod = "SUPER"

    hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
    hl.bind(mainMod .. " + C", hl.dsp.window.close())
    hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen()) -- Fullscreen toggle
    hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
    hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
    hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
    hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
    hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
    hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

    for i = 1, 10 do
        local key = i % 10
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
        end

        hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
        hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

        hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
        hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

        hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),    { mouse = true })
        hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

        -- Wallpaper selector, power menu, control center

        -- Screenshots
        hl.bind("Print", hl.dsp.exec_cmd('mkdir -p $HOME/Pictures/Screenshots; f=$HOME/Pictures/Screenshots/$(date +%F_%H-%M-%S).png; grim "$f" && wl-copy < "$f" && notify-send "Screenshot saved" "$f"'))
        hl.bind("SHIFT + Print", hl.dsp.exec_cmd('mkdir -p $HOME/Pictures/Screenshots; f=$HOME/Pictures/Screenshots/$(date +%F_%H-%M-%S).png; grim -g "$(slurp)" "$f" && wl-copy < "$f" && notify-send "Screenshot saved" "$f"'))

        -- Media / brightness
        hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
        hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
        hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
        hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),   { locked = true })
        hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
        hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
        hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

        --------------------------------
        ---- WINDOWS AND WORKSPACES ----
        --------------------------------
        hl.window_rule({
            name  = "suppress-maximize-events",
            match = { class = ".*" },
            suppress_event = "maximize",
        })

        hl.window_rule({
            name  = "fix-xwayland-drags",
            match = {
                class = "^$", title = "^$",
                xwayland = true, float = true, fullscreen = false, pin = false,
            },
            no_focus = true,
        })

        hl.window_rule({
            name  = "kitty-glass-blur",
            match = { class = "kitty" },
            opacity = 0.65,
        })
        local menu = "qs ipc call menu toggle apps"


        -----------------------------
---- QUICKSHELL KEYBINDS ----
-----------------------------
local function qs(cmd) return hl.dsp.exec_cmd("qs ipc call " .. cmd) end
local function sh(cmd) return hl.dsp.exec_cmd(cmd) end

hl.bind(mainMod .. " + Tab",       qs("menu toggle windows"))
hl.bind(mainMod .. " + Escape",    qs("menu toggle power"))
hl.bind(mainMod .. " + D",         qs("dashboard toggle"))
hl.bind(mainMod .. " + B",         qs("menu toggle settings"))
hl.bind(mainMod .. " + W",         qs("wallpapers toggle"))
hl.bind(mainMod .. " + SHIFT + V", qs("clipboard toggle"))
hl.bind(mainMod .. " + A",         qs("menu toggle audio"))
hl.bind(mainMod .. " + T",         qs("menu toggle tools"))
hl.bind(mainMod .. " + N",         qs("menu toggle wifi"))
hl.bind(mainMod .. " + SHIFT + B", qs("menu toggle bluetooth"))
hl.bind(mainMod .. " + SHIFT + T", sh("$HOME/.local/bin/setwall --cycle"))
hl.bind(mainMod .. " + SHIFT + W", sh("$HOME/.local/bin/setwall --random"))

-- HyprMod managed settings
        require("hyprland-gui")
