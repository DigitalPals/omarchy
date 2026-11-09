-- CybexOS defaults: no focus stealing, rounded corners, no window borders.
hl.config({
  general = { border_size = 0 },
  decoration = { rounding = 16 },
  misc = { focus_on_activate = false },
})

-- CybexOS default: a lone tiled window on an external monitor gets a 15% margin
-- on each side. Updates when monitors are plugged in or rearranged.
local single_window_rules = {}

local function update_single_window_margins()
  local connected = {}

  for _, monitor in ipairs(hl.get_monitors()) do
    if not monitor.name:match("^eDP%-") and not monitor.name:match("^LVDS%-") and not monitor.is_mirror then
      connected[monitor.name] = true

      local rotated = monitor.transform % 2 == 1
      local width = (rotated and monitor.height or monitor.width) / monitor.scale
      local margin = math.floor(width * 0.15 + 0.5)
      local entry = single_window_rules[monitor.name]

      if not entry or entry.margin ~= margin then
        if entry then
          entry.rule:set_enabled(false)
        end

        single_window_rules[monitor.name] = {
          margin = margin,
          rule = hl.workspace_rule({
            workspace = "m[" .. monitor.name .. "] w[t1]",
            gaps_out = { top = 10, right = margin, bottom = 10, left = margin },
          }),
        }
      end
    end
  end

  for name, entry in pairs(single_window_rules) do
    if not connected[name] then
      entry.rule:set_enabled(false)
      single_window_rules[name] = nil
    end
  end
end

hl.on("monitor.layout_changed", update_single_window_margins)
update_single_window_margins()

-- CybexOS default: slide between workspaces. Omarchy turns this off.
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
