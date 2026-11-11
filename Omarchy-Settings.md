# Omarchy Settings: setup prompt

> **Status: work in progress.** New preferences get added over time. To add one, put it in the matching section and add a line to the [Changelog](#changelog).
>
> To use it, paste the prompt from [README.md](README.md) into an AI agent on the target computer. The agent reads this file and follows everything below the line. It needs the `files/` folder too.

---

## Your task

Apply my personal Omarchy preferences to this computer. They give Omarchy the keybindings and defaults I'm used to from CybexOS. Apply every step below, validate, then report what changed, what you skipped and why.

Each step names a file in the `files/` folder next to this document. Use those files as they are and don't retype their contents. If the folder is missing, stop and ask me for it.

Written against Omarchy 4.5.0-3 and Hyprland 0.56.2, which use Lua config (`~/.config/hypr/*.lua`).

## Rules

1. If an `omarchy` skill is available, load it first.
2. Never edit anything in `/usr/share/omarchy/`. Reading it is fine. All changes go in user config.
3. Back up every file before changing it: `cp -p FILE FILE.bak.$(date +%s)`.
4. Run `omarchy version` first. If Hyprland config here isn't Lua, stop and ask me before translating anything.
5. Run `omarchy menu keybindings --print` first. If a key under "New keys" below is already taken by something I added on this computer, ask me before replacing it.
6. Don't run anything from the CybexOS repo. It's NixOS-based, and its `cybexos-*` commands don't exist on Omarchy.
7. Files ending in `.append`, `.append.lua` or `.append.fish` get added to the end of the target file. First check whether their block is already there, so nothing is added twice. Don't overwrite personal settings already in those files.

## Step 1: Install packages

Install `lazydocker`, `git-delta` and `fish`. Do this before Step 5, because git fails on every paged command if `core.pager` points at a missing `delta`, and the login shell can't change until fish is installed.

```bash
omarchy pkg add lazydocker git-delta fish
```

If no terminal is available for a password, use `pkexec pacman -S --needed --noconfirm lazydocker git-delta fish`.

## Step 2: Keybindings

Append to `~/.config/hypr/bindings.lua`.

### Keys that differ from Omarchy's defaults

| Key | My preference | Omarchy default |
|---|---|---|
| Super+W | WhatsApp | Close window (Super+Q still closes) |
| Super+L | Lock | Cycle workspace layout |
| Super+Ctrl+L | Cycle workspace layout | Lock |
| Super+F | Toggle floating | Fullscreen |
| Super+Shift+F | Fullscreen | File manager |
| Super+Space | Apps | Omarchy menu |
| Super+Alt+Space | Omarchy menu | Apps |
| Super+Shift+B | Private browser | Browser |
| Super+Alt+←/→ | Previous/next window in group | Move window into group |
| Super+` | Screenshot | Toggle Quake console (now Super+Alt+`) |
| Super+S | Spotify | Toggle scratchpad (no replacement key) |

### New keys

Super+B browser, Super+E files, Super+Y YouTube, Super+N notification history, Super+Z 2x zoom toggle, F9 dictation, Super+Ctrl+G move window out of group, Shift+Print full-screen screenshot, Super+D lazydocker, Super+Shift+V paste a copied image as a file path, Super+Alt+` Quake console.

### Code

**File:** `files/hypr-bindings.append.lua`

**F9:** this binding needs Superwhisper. If `command -v superwhisper` finds nothing, use `"omarchy-dictation toggle"` instead and tell me.

**Super+Shift+V:** this binding needs a script. Copy the file below to `~/.local/bin/clipboard-image-to-file` and make it executable with `chmod 0755`. It saves the copied image to `~/.cache/clipboard-images/`, pastes its file path for terminal apps like Claude Code, then puts the image back on the clipboard. In Claude Code, plain Ctrl+V also attaches a copied image directly.

**File:** `files/clipboard-image-to-file`

## Step 3: Input

Append to `~/.config/hypr/input.lua`.

**File:** `files/hypr-input.append.lua`

## Step 4: Look and behaviour

Append to `~/.config/hypr/looknfeel.lua`. This covers no focus stealing, 16 px rounded corners, no window borders, a 15% side margin for a single tiled window on any external monitor, and a slide animation between workspaces. The margin code finds monitors on its own, so it needs no monitor names.

**File:** `files/hypr-looknfeel.append.lua`

## Step 5: Terminal, git, screensaver, shell

**foot** (`~/.config/foot/foot.ini`): don't replace the whole file. Change its existing values to match this file and add the `[mouse]` section.

**File:** `files/foot.settings.ini`

**git** (`~/.config/git/config`): add these sections.

**File:** `files/git-config.append`

**Screensaver** (`~/.config/omarchy/shell.json`): set `idle.screensaver` to `0`, which disables it. Leave `idle.lock` as it is.

**Passwordless sudo icon** (`~/.config/omarchy/shell.json`): hide the red icon next to the clock. Find the `omarchy.indicators` entry in `bar.layout` and set its `items` key to this list, which is every indicator except `PasswordlessSudo`. Keep the rest of the entry. This only hides the icon, so don't turn passwordless sudo on or off for this. The shell reloads the file automatically.

**File:** `files/shell-indicators.items.json`

**Fish shell:** make fish my login shell, with Omarchy's bash defaults carried over. Omarchy only ships bash config, so these files are the port. Leave `~/.bashrc` as it is, so bash still works as a fallback.

Copy these into place, creating the directories if needed. They replace the target file, so back up any that already exist:

| File | Target |
|---|---|
| `files/fish-conf.d-omarchy.fish` | `~/.config/fish/conf.d/omarchy.fish` |
| `files/fish-completions-omarchy.fish` | `~/.config/fish/completions/omarchy.fish` |

The port loads Starship, mise, zoxide and fzf, and defines Omarchy's aliases and functions. It uses Omarchy's own `env-bootstrap` and `fns/*` scripts for the environment and for the tmux, herdr, rsync, drive and `ssh` helpers. Check that those two still exist under `/usr/share/omarchy/default/bash/`. If they've moved, stop and ask me.

**Shell aliases** (`~/.config/fish/config.fish`, which loads after the port, so these win):

**File:** `files/fish-config.append.fish`

These hide Ghostscript's `gs` and Graphviz's `gc`, in interactive shells only. They also replace Omarchy's `ga` worktree command with `git add`, and make `claude` and `codex` start in YOLO mode, with no permission prompts and, for Codex, no sandbox. `cx` and `cy` are redefined to match, because Omarchy's versions pass flags that conflict with these. That's all intended. If your permissions block editing `~/.config/fish/config.fish`, don't work around it. Give me the lines to paste.

**Login shell:** do this last, after the files above are in place and `fish -ic 'functions -q zd tdl gs; and echo ok'` prints `ok`:

```bash
sudo chsh -s /usr/bin/fish "$USER"
```

If no terminal is available for a password, use `pkexec chsh -s /usr/bin/fish "$USER"`. Don't log me out yourself. Tell me to log out and back in, because new terminals can keep opening bash until I do.

## Step 6: Terminal prompt

Back up `~/.config/starship.toml`, then replace it with `files/starship.toml`. It recreates the CybexOS prompt (the oh-my-posh theme `EDM115-newline2`) in Starship, which the fish config from Step 5 already loads, so don't install oh-my-posh or edit the fish config for this.

The look: two lines. The top line is `╭─`, the OS icon and the full path on the left, with capsules for git and for Node, npm, pnpm, Python, Java and PHP on the right. The bottom line is `╰─ >`.

Copy the file as it is rather than retyping it, because its `\u` escapes must stay as text. It needs a Nerd Font in the terminal.

**File:** `files/starship.toml`

Check it from inside a git repo in a real interactive shell, with `fish -ic 'starship prompt --terminal-width 130'`. Open a new terminal after logging back in to see it.

Known differences from the original: there's no upstream (GitHub) icon in the git capsule, and capsules don't hide themselves in narrow terminals.

## Step 7: Menubar

This gives the bar the CybexOS "hug" look, extended to the whole desktop: concave corners in the bar color under both ends of the bar, pure black corners on the opposite screen edge, and a 33 px bar with 13 px text and icons. Omarchy's defaults are 26 px and 12 px.

**Hug corners:** copy the folder below to `~/.config/omarchy/plugins/john.hug-corners/`, keeping its files as they are. The plugin is already adapted for Omarchy, so don't fetch anything from CybexOS. Then enable it:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/john.hug-corners
omarchy-shell shell rescanPlugins
omarchy plugin enable john.hug-corners
```

**File:** `files/shell-plugin-hug-corners/`

**Bar and text size:** copy these into place, creating the directory if needed. They apply to every theme.

| File | Target |
|---|---|
| `files/themed-shell.bar.toml.tpl` | `~/.config/omarchy/themed/shell.bar.toml.tpl` |
| `files/themed-shell.font.toml.tpl` | `~/.config/omarchy/themed/shell.font.toml.tpl` |

Then run `omarchy theme refresh`, which applies them and leaves the wallpaper alone. Use `refresh` rather than `omarchy theme set`. `size-horizontal = 30` is correct for a 33 px bar, because Omarchy scales it with the font size.

The font size is shell-wide, so menus, panels and notifications also get about 8% larger.

Known limits: the corners only draw with an opaque bar on the top or bottom edge, and hide for a glassy or clear bar. They match window corners at `rounding_power` 2, so Omarchy's `corners-rounded` toggle (power 3) changes the window curve but not theirs.

**Workspace indicator:** this replaces Omarchy's workspace widget with the CybexOS look. The active workspace is a numbered accent chip that slides between slots, workspaces with windows show their number, and empty ones are dots. Copy the folder below to `~/.config/omarchy/plugins/john.workspaces/`, keeping its files as they are. Then, in `~/.config/omarchy/shell.json`, change the `omarchy.workspaces` entry in `bar.layout` to `john.workspaces`, keeping its position, and run `omarchy restart shell`.

**File:** `files/shell-plugin-workspaces/`

It doesn't show the workspace layout, and clicking the active chip does nothing. Super+Ctrl+L still cycles layouts. Digit centering is tuned for JetBrains Mono, so a very different bar font may sit slightly off.

**Model Usage instead of Agents:** I use my own Model Usage widget ([DigitalPals/omarchy-modelusage](https://github.com/DigitalPals/omarchy-modelusage)) for AI usage and limits, so it replaces Omarchy's Agents widget. If `omarchy plugin list` already shows `digitalpals.model-usage`, for example as a symlink to a local checkout, leave it as it is and skip the `add`. Otherwise add it from git:

```bash
omarchy plugin add https://github.com/DigitalPals/omarchy-modelusage.git --enable --yes
omarchy bar move digitalpals.model-usage --before omarchy.keyboard-layout
omarchy plugin disable omarchy.agents
```

`omarchy plugin disable` takes Agents off the bar and keeps it off. Agents is only a bar widget, so nothing else stops. Don't install anything extra for Model Usage. Its optional Fusebox live activity needs Python `websockets`, and without it the widget just shows live activity as unavailable. Don't copy provider, proxy or key settings from another computer. I set those up in the widget's own settings.

## Step 8: Lock screen

This gives Omarchy's lock screen the CybexOS password field: a dark surface at 85% over the blurred wallpaper, a thin neutral 2 px outline instead of the 3 px accent one, muted placeholder text and a red outline after a wrong password. It only uses theme colours, so the lock itself stays Omarchy's. Don't install hyprlock or clone the `omarchy.lock` plugin for this.

Copy this into place. It applies to every theme:

| File | Target |
|---|---|
| `files/themed-shell.lock.toml.tpl` | `~/.config/omarchy/themed/shell.lock.toml.tpl` |

**Tokyo Night:** it's the only stock theme that ships its own `shell.lock.toml`, and a theme's own file wins over the template above. So also copy the overlay below, which has the same look in Tokyo Night's colours. Copy it even if Tokyo Night isn't the current theme.

| File | Target |
|---|---|
| `files/theme-tokyo-night.shell.lock.toml` | `~/.config/omarchy/themes/tokyo-night/shell.lock.toml` |

Then run `omarchy theme refresh`. If any other theme in `/usr/share/omarchy/themes/*/shell.lock.toml` ships a lock file by now, tell me instead of writing an overlay for it.

Known limits: there's no clock or date, the field keeps Omarchy's size (381×67 instead of 300×54), the wallpaper isn't dimmed, the outline doesn't turn accent while the password is checked, and the corner radius follows Hyprland's `rounding`. Those need changes to Omarchy's lock plugin (see Open items).

## Step 9: Validate

Run this with bash, because the `for` loop isn't valid fish.

```bash
hyprctl reload
hyprctl configerrors     # must print nothing
for o in input:natural_scroll input:touchpad:natural_scroll misc:focus_on_activate general:border_size decoration:rounding; do
  echo "$o: $(hyprctl getoption $o | head -1)"
done                     # expect true, true, false, 0, 16
omarchy menu keybindings --print | grep -E 'WhatsApp|Spotify|Lock system|Toggle zoom|lazydocker|Paste copied image|Toggle Quake'
command -v clipboard-image-to-file            # expect ~/.local/bin/clipboard-image-to-file
hyprctl workspacerules | grep -A8 'w\[t1\]'   # only with an external monitor connected
hyprctl animations -j | jq -c '.[0][] | select(.name == "workspaces") | [.enabled, .speed, .bezier]'  # expect [true,6.00,"default"]
foot --check-config
git config --global core.pager                # expect delta
getent passwd "$USER" | cut -d: -f7           # expect /usr/bin/fish
fish -ic 'functions -q zd tdl gs; and echo ok' # expect ok
fish -ic 'functions claude codex' | grep -c dangerously  # expect 4
omarchy plugin list | grep john.hug-corners   # expect enabled
hyprctl layers | grep -c john-hug-corners     # expect two per monitor; can take a few seconds to appear
hyprctl monitors -j | jq -c '.[].reserved'    # expect [0,33,0,0] for each monitor
omarchy plugin list | grep -E 'john.workspaces|omarchy.workspaces'  # expect john.workspaces enabled, omarchy.workspaces disabled
omarchy plugin list | grep -E 'digitalpals.model-usage|omarchy.agents'  # expect model-usage enabled, agents disabled
awk '/^\[lock\]/{p=1;next} /^\[/{p=0} p' ~/.local/state/omarchy/current/theme/shell.toml | grep -E '^(background-alpha|border-width) '  # expect 0.85 and 2
```

To look at the lock screen without locking, run `omarchy-shell lock preview`, then `omarchy-shell lock hidePreview` (or click it).

If `hyprctl configerrors` reports anything, fix it and validate again. foot changes only show in new windows.

## Do not apply

Don't add these, even if they look useful:

- **`lv3:ralt_switch` in `kb_options`:** it changes what Right Alt sends, which would likely break Omarchy's `ALT + Alt_R` push-to-talk.
- **SSH `IdentityAgent ~/.1password/agent.sock`:** only valid if that socket exists, and I haven't asked for it.
- **Adding my account to the `docker` group:** it's effectively root access. Super+D falls back to `sudo` instead.
- **Installing `xclip`:** Claude Code tries it before `wl-paste`, and it has been reported to break image paste on Wayland.

## Considered and not chosen

I reviewed these and didn't pick them. Leave them unless I ask:

- Touchpad `scroll_factor = 1.0` (Omarchy uses 0.4)
- Three-finger swipe between workspaces
- Caps Lock as Compose (`compose:caps`)
- Key repeat delay of 600 ms (Omarchy uses 250 ms)

## Open items

Not yet decided or done:

- Key for scrolling screenshots: `omarchy capture screenshot scroll` exists but has no key yet.
- No Omarchy equivalent found yet for the Super+Tab window overview, game mode or the Super+I assistant.
- Lock screen clock and date: the CybexOS lock shows a large clock and the date above the password field. Omarchy's lock plugin has no setting for this, and cloning it would freeze its authentication code, so the route is an upstream Omarchy PR for an optional clock and date.

## Report back

When you finish, tell me:

- Which steps were applied, and any you adapted (such as the F9 fallback)
- Any keys you replaced, and what they did before
- The path of each backup file
- Anything you couldn't validate

## Changelog

- **2026-11-11:** My Model Usage widget replaces Omarchy's Agents widget in the bar (Step 7).
- **2026-11-11:** Added the CybexOS lock screen password field through theme colours, with an overlay for Tokyo Night (Step 8). Validate is now Step 9.
- **2026-11-09:** Super+S launches Spotify, replacing Omarchy's scratchpad toggle (Step 2).
- **2026-11-09:** The workspace indicator now shows numbers for workspaces with windows, and dots only for empty ones (Step 7).
- **2026-11-09:** `claude` and `codex` start in YOLO mode in interactive fish shells, as on CybexOS, and `cx` and `cy` match. Removed from "Do not apply" (Step 5).
- **2026-11-09:** Added Super+` for screenshots and Super+Shift+V to paste a copied image as a file path. The Quake console moved to Super+Alt+` (Step 2).
- **2026-11-09:** Added the CybexOS slide animation between workspaces (Step 4).
- **2026-11-09:** Added the CybexOS-style workspace indicator: dots with a numbered accent chip for the active workspace (Step 7).
- **2026-11-09:** Added CybexOS-style hug corners under the bar, pure black corners on the opposite screen edge, and a 33 px bar with 13 px text and icons (Step 7). Validate is now Step 8.
- **2026-11-08:** Switched the login shell to fish with a port of Omarchy's bash defaults. The git aliases moved from `~/.bashrc` to fish (Steps 1, 5, 6, 7).
- **2026-11-08:** Hide the passwordless sudo icon in the bar (Step 5).
- **2026-11-08:** Moved all config snippets into `files/`; the steps now point to them.
- **2026-11-08:** Added the CybexOS terminal prompt style, recreated in Starship (Step 6).
- **2026-11-08:** First version. CybexOS-style keybindings, natural scrolling, no focus stealing, look and feel, foot, git with delta, screensaver off, git aliases.
