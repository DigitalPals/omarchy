# Fish port of Omarchy's bash defaults (/usr/share/omarchy/default/bash).
# Put your own settings in ~/.config/fish/config.fish, which loads after this.

# OMARCHY_PATH and PATH, needed even for non-interactive shells. Reuses
# Omarchy's own script so future changes to it apply here too.
if test -r /usr/share/omarchy/default/bash/env-bootstrap
    set -l omarchy_env (sh -c '. /usr/share/omarchy/default/bash/env-bootstrap; printf "%s\n%s\n" "$OMARCHY_PATH" "$PATH"')
    set -gx OMARCHY_PATH $omarchy_env[1]
    set -gx PATH (string split : -- $omarchy_env[2])
end

status is-interactive; or return

set -g fish_greeting

# Environment. EDITOR must be a list: fish doesn't word-split variables, so
# `$EDITOR file` would otherwise look for a command with a space in its name.
# Lists are exported space-joined, so child processes see the usual string.
if set -q EDITOR
    set -gx EDITOR (string split ' ' -- $EDITOR)
else
    set -gx EDITOR omarchy-launch-editor --inline
end
set -gx SUDO_EDITOR $EDITOR
set -q BROWSER; or set -gx BROWSER omarchy-launch-browser
set -gx BAT_THEME ansi
set -gx MANROFFOPT -c
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Tool integrations
command -q mise; and mise activate fish | source
if test "$TERM" != dumb; and command -q starship
    starship init fish | source
end
command -q zoxide; and zoxide init fish | source
command -q fzf; and functions -q fzf_key_bindings; and fzf_key_bindings

if command -q try
    function try
        functions --erase try
        SHELL=(status fish-path) command try init ~/Work/tries | string collect | source
        try $argv
    end
end

# File system
if command -q eza
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
end

# fzf runs previews with $SHELL, and these previews are POSIX shell.
function ff
    if test "$TERM" = xterm-kitty
        fzf --with-shell 'bash -c' --preview 'case $(file --mime-type -b {}) in image/*) kitty icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {} ;; *) bat --style=numbers --color=always {} ;; esac' $argv
    else
        fzf --with-shell 'bash -c' --preview 'bat --style=numbers --color=always {}' $argv
    end
end

function eff
    $EDITOR "$(ff)"
end

function sff
    if test (count $argv) -eq 0
        echo "Usage: sff <destination> (e.g. sff host:/tmp/)"
        return 1
    end
    set -l file (find . -type f -printf '%T@\t%p\n' | sort -rn | cut -f2- | ff)
    and test -n "$file"
    and scp $file $argv[1]
end

if command -q zoxide
    function zd
        if test (count $argv) -eq 0
            __zoxide_cd_internal ~
        else if test -d "$argv[1]"
            __zoxide_cd_internal $argv[1]
        else
            if not z $argv
                echo "Error: Directory not found"
                return 1
            end
            printf '\U000F17A9 '
            pwd
        end
    end
    alias cd=zd
end

function open
    command xdg-open $argv >/dev/null 2>&1 &
    disown
end

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias a='omarchy-agent --inline'
alias c='opencode --auto'
alias cx='printf "\033[2J\033[3J\033[H"; and claude --permission-mode auto'
alias cy='codex --approve-for-me'
alias d='docker'
alias r='rails'
alias t='tmux attach; or tmux new -s Work'
alias h='herdr'
alias ic='tdl c'
alias ix='tdl cx'
alias icx='tdl c cx'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
alias decompress='tar -xzf'

function n
    if test (count $argv) -eq 0
        command nvim .
    else
        command nvim $argv
    end
end

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Worktrees. Native because they have to change this shell's directory.
function ga
    if test -z "$argv[1]"
        echo "Usage: ga [branch name]"
        return 1
    end
    set -l branch $argv[1]
    set -l wt_path "../"(path basename $PWD)"--$branch"
    git worktree add -b $branch $wt_path
    mise trust $wt_path
    cd $wt_path
end

function gd
    if gum confirm "Remove worktree and branch?"
        set -l cwd (pwd)
        set -l worktree (path basename $cwd)
        set -l root (string replace -r -- '--.*$' '' $worktree)
        set -l branch (string replace -r -- '^.*?--' '' $worktree)
        # Protect against accidentally nuking a non-worktree directory
        if test "$root" != "$worktree"
            cd "../$root"
            git worktree remove $cwd --force; or return 1
            git branch -D $branch
        end
    end
end

# Everything else runs Omarchy's own bash function, so updates apply here too.
function __omarchy_bash_fn
    bash -c 'source "$OMARCHY_PATH/default/bash/fns/$1"; shift; "$@"' omarchy-fn $argv
end

for entry in compression:compress \
        drives:iso2sd drives:format-drive \
        herdr:hdl herdr:hds herdr:hdlm herdr:hsl \
        rsyncing:rsw rsyncing:lsw rsyncing:dsw \
        ssh-port-forwarding:fip ssh-port-forwarding:dip ssh-port-forwarding:lip \
        ssh-reconnect:ssh \
        tmux:tdl tmux:tds tmux:tdlm tmux:tsl
    set -l parts (string split : -- $entry)
    function $parts[2] --inherit-variable parts
        __omarchy_bash_fn $parts $argv
    end
end
