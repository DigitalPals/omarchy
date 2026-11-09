-- CybexOS muscle memory: keys that do something different on Omarchy.
o.rebind("SUPER + W", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true }) -- was: close window (Super+Q still closes)
o.rebind("SUPER + L", "Lock system", "omarchy-system-lock") -- was: cycle workspace layout
o.rebind("SUPER + CTRL + L", "Cycle workspace layout", "omarchy-hyprland-workspace-layout-toggle") -- was: lock system
o.rebind("SUPER + F", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" })) -- was: full screen
o.rebind("SUPER + SHIFT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- was: file manager (now Super+E)
o.rebind("SUPER + SPACE", "Apps", "omarchy-shell omarchy.dock apps") -- was: Omarchy menu
o.rebind("SUPER + ALT + SPACE", "Omarchy menu", { menu = "root" }) -- was: apps
o.rebind("SUPER + SHIFT + B", "Browser (private)", { omarchy = "browser --private" }) -- was: browser (now Super+B)
o.rebind("SUPER + ALT + LEFT", "Previous window in group", hl.dsp.group.prev()) -- was: move window to group on left
o.rebind("SUPER + ALT + RIGHT", "Next window in group", hl.dsp.group.next()) -- was: move window to group on right
o.rebind("SUPER + grave", "Screenshot", "omarchy-capture-screenshot") -- was: toggle Quake console (now Super+Alt+grave)
o.rebind("SUPER + S", "Spotify", { omarchy = "spotify" }) -- was: toggle scratchpad

-- CybexOS keys that are free on Omarchy.
o.bind("SUPER + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + E", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + Y", "YouTube", { webapp = "https://youtube.com/" })
o.bind("SUPER + N", "Open notification history", { ipc = "notifications.showHistory" })
o.bind("SUPER + Z", "Toggle zoom", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom > 1.01 and 1 or 2 } })
end)
o.bind("F9", "Superwhisper: toggle dictation", "superwhisper record")
o.bind("SUPER + CTRL + G", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))
o.bind("SHIFT + PRINT", "Screenshot full screen", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + V", "Paste copied image as a file path", "clipboard-image-to-file")
o.bind("SUPER + ALT + grave", "Toggle Quake console", hl.dsp.workspace.toggle_special("qconsole"))
-- Falls back to sudo because this account is not in the docker group.
o.bind("SUPER + D", "Docker (lazydocker)", "omarchy-launch-tui --app-id=org.omarchy.lazydocker sh -c 'docker info >/dev/null 2>&1 && exec lazydocker; exec sudo lazydocker'")
