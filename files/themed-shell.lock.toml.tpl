[lock]
# Replaces the whole [lock] section of the generated shell.toml, for every theme.
# The CybexOS lock screen's password field: a surface one step up from the
# base colour at 85%, a thin neutral outline instead of the accent one, and
# muted placeholder text. `mix a b N%` is colour a with N% of colour b.
background       = "{{ mix background foreground 4% }}"
background-alpha = 0.85
text             = "{{ foreground }}"
placeholder      = "{{ mix foreground background 30% }}"
text-error       = "{{ red }}"
# The field shows border-active while idle, typing and checking, and
# border-error after a wrong password. `border` is kept for completeness.
border           = "{{ mix background foreground 15% }}"
border-active    = "{{ mix background foreground 15% }}"
border-error     = "{{ red }}"
border-alpha     = 1.0
# Omarchy's default is 3 px.
border-width     = 2
selection        = "{{ accent }}"
selection-alpha  = 0.45
