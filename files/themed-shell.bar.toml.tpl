[bar]
# Replaces the whole [bar] section of the generated shell.toml, for every theme.
# Alpha companions (where present) range from 0 (invisible) to 1 (opaque).
background       = "{{ background }}"
background-alpha = 1.0
text             = "{{ foreground }}"
# Modules calling attention to themselves (recording, voxtype, alerts, updates)
active           = "{{ red }}"
# Sizes are stated at font base-size 12 and scale with it: at base-size 13,
# size-horizontal 30 draws a 33 px bar. Omarchy's default is 26.
scale-with-font  = true
size-horizontal  = 30
size-vertical    = 28
