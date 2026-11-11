# Omarchy settings

My personal preferences for [Omarchy](https://omarchy.org/), packaged so an AI agent can apply them to a computer. They bring over the keybindings, menubar and defaults I'm used to from CybexOS.

## Install

Open an AI agent on the target computer, such as Claude Code or Codex, and paste this:

```text
Clone https://github.com/DigitalPals/omarchy into ~/Code/omarchy. If that folder already exists, run `git pull` there instead. Then read Omarchy-Settings.md in that folder and follow all of its instructions below the line, using the files/ folder next to it. When you finish, give me the report that document asks for.
```

The agent does the rest, including backups and validation.

## Before you run it

- **Omarchy version:** it's written for Omarchy 4.5.0-3 and Hyprland 0.56.2, which use Lua config. The agent stops and asks if Hyprland's config isn't Lua.
- **Password:** installing packages and changing the login shell need `sudo`, so have your password ready. The agent uses `pkexec` if it has no terminal for the prompt.
- **Log out afterwards:** the login shell changes to fish, which takes effect after logging out and back in.

## What it changes

- **Keybindings:** CybexOS-style keys, including Super+W for WhatsApp, Super+S for Spotify, Super+L to lock and Super+F to float a window. Super+Q still closes windows.
- **Menubar:** a 33 px bar with hug corners, a workspace indicator with a sliding accent chip, and the [Model Usage](https://github.com/DigitalPals/omarchy-modelusage) widget in place of Omarchy's Agents widget. Menus, panels and notifications get about 8% larger text.
- **Lock screen:** the CybexOS password field, with a dark surface and a thin neutral outline. It's done with theme colours only, so there's no clock or date yet.
- **Look and behaviour:** 16 px rounded corners, no window borders, no focus stealing, and a slide animation between workspaces.
- **Screenshots:** Super+` takes a screenshot, and Super+Shift+V pastes a copied image into a terminal as a file path. The Quake console moves to Super+Alt+`.
- **Terminal and shell:** fish as the login shell with Omarchy's bash defaults ported over, the CybexOS Starship prompt, foot settings, and git with delta.

## Warning: YOLO mode

This setup makes `claude` and `codex` start in YOLO mode in interactive fish shells. Neither asks before running commands or editing files, and Codex also runs without its sandbox. A bad command or a prompt injection can act with your full account access.

To run one normally, use `command claude` or `command codex`. To turn it off for good, tell the agent to leave those aliases out of `files/fish-config.append.fish`, or delete them from `~/.config/fish/config.fish` afterwards.

## What's in here

- [`Omarchy-Settings.md`](Omarchy-Settings.md) is the full set of instructions the agent follows, with a changelog.
- [`files/`](files/) holds the config snippets, scripts and shell plugins those instructions install.

Parts of the shell plugins and the image paste script are adapted from [CybexOS](https://github.com/CybexHQ/CybexOS), under the MIT License.
