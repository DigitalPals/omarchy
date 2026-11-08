# Omarchy Settings: setup prompt

> **Status: work in progress.** New preferences get added over time. To add one, put it in the matching section and add a line to the [Changelog](#changelog).
>
> To use it, copy this whole `Omarchy-Settings` directory to the target computer, then tell an AI agent there to read this file and follow everything below the line. The agent needs the `files/` folder too.

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
7. Files ending in `.append` or `.append.lua` get added to the end of the target file. First check whether their block is already there, so nothing is added twice. Don't overwrite personal settings already in those files.

## Step 1: Install packages

Install `lazydocker` and `git-delta`. Do this before Step 5, because git fails on every paged command if `core.pager` points at a missing `delta`.

```bash
omarchy pkg add lazydocker git-delta
```

If no terminal is available for a password, use `pkexec pacman -S --needed --noconfirm lazydocker git-delta`.

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

### New keys

Super+B browser, Super+E files, Super+Y YouTube, Super+N notification history, Super+Z 2x zoom toggle, F9 dictation, Super+Ctrl+G move window out of group, Shift+Print full-screen screenshot, Super+D lazydocker.

### Code

**File:** `files/hypr-bindings.append.lua`

**F9:** this binding needs Superwhisper. If `command -v superwhisper` finds nothing, use `"omarchy-dictation toggle"` instead and tell me.

## Step 3: Input

Append to `~/.config/hypr/input.lua`.

**File:** `files/hypr-input.append.lua`

## Step 4: Look and behaviour

Append to `~/.config/hypr/looknfeel.lua`. This covers no focus stealing, 16 px rounded corners, no window borders, and a 15% side margin for a single tiled window on any external monitor. The margin code finds monitors on its own, so it needs no monitor names.

**File:** `files/hypr-looknfeel.append.lua`

## Step 5: Terminal, git, screensaver, shell

**foot** (`~/.config/foot/foot.ini`): don't replace the whole file. Change its existing values to match this file and add the `[mouse]` section.

**File:** `files/foot.settings.ini`

**git** (`~/.config/git/config`): add these sections.

**File:** `files/git-config.append`

**Screensaver** (`~/.config/omarchy/shell.json`): set `idle.screensaver` to `0`, which disables it. Leave `idle.lock` as it is.

**Shell aliases** (`~/.bashrc`, below the line that sources Omarchy's `rc`):

**File:** `files/bashrc.append`

These hide Ghostscript's `gs` and Graphviz's `gc`, in interactive shells only. That's intended. If your permissions block editing `~/.bashrc`, don't work around it. Give me the lines to paste.

## Step 6: Terminal prompt

Back up `~/.config/starship.toml`, then replace it with `files/starship.toml`. It recreates the CybexOS prompt (the oh-my-posh theme `EDM115-newline2`) in Starship, which Omarchy's bash already loads, so don't install oh-my-posh or edit `~/.bashrc` for this.

The look: two lines. The top line is `╭─`, the OS icon and the full path on the left, with capsules for git and for Node, npm, pnpm, Python, Java and PHP on the right. The bottom line is `╰─ >`.

Copy the file as it is rather than retyping it, because its `\u` escapes must stay as text. It needs a Nerd Font in the terminal.

**File:** `files/starship.toml`

Check it from inside a git repo in a real interactive shell, with `bash -ic 'starship prompt --terminal-width 130'`. Open a new terminal to see it.

Known differences from the original: there's no upstream (GitHub) icon in the git capsule, and capsules don't hide themselves in narrow terminals.

## Step 7: Validate

```bash
hyprctl reload
hyprctl configerrors     # must print nothing
for o in input:natural_scroll input:touchpad:natural_scroll misc:focus_on_activate general:border_size decoration:rounding; do
  echo "$o: $(hyprctl getoption $o | head -1)"
done                     # expect true, true, false, 0, 16
omarchy menu keybindings --print | grep -E 'WhatsApp|Lock system|Toggle zoom|lazydocker'
hyprctl workspacerules | grep -A8 'w\[t1\]'   # only with an external monitor connected
foot --check-config
git config --global core.pager                # expect delta
```

If `hyprctl configerrors` reports anything, fix it and validate again. foot changes only show in new windows.

## Do not apply

Don't add these, even if they look useful:

- **`lv3:ralt_switch` in `kb_options`:** it changes what Right Alt sends, which would likely break Omarchy's `ALT + Alt_R` push-to-talk.
- **`claude --dangerously-skip-permissions` or `codex --dangerously-bypass-approvals-and-sandbox` as aliases:** they turn off the safety prompts for every session.
- **SSH `IdentityAgent ~/.1password/agent.sock`:** only valid if that socket exists, and I haven't asked for it.
- **Adding my account to the `docker` group:** it's effectively root access. Super+D falls back to `sudo` instead.

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

## Report back

When you finish, tell me:

- Which steps were applied, and any you adapted (such as the F9 fallback)
- Any keys you replaced, and what they did before
- The path of each backup file
- Anything you couldn't validate

## Changelog

- **2026-11-08:** Moved all config snippets into `files/`; the steps now point to them.
- **2026-11-08:** Added the CybexOS terminal prompt style, recreated in Starship (Step 6).
- **2026-11-08:** First version. CybexOS-style keybindings, natural scrolling, no focus stealing, look and feel, foot, git with delta, screensaver off, git aliases.
