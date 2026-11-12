# BEGIN omarchy-settings: fish-config (managed block, replaced on update)
# CybexOS git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias lg='lazygit'

# CybexOS default: interactive Claude and Codex start in YOLO mode, with no
# permission prompts and, for Codex, no sandbox. `command claude` and
# `command codex` run them normally.
if status is-interactive
    alias claude='claude --dangerously-skip-permissions'
    alias codex='codex --dangerously-bypass-approvals-and-sandbox'
    # Omarchy's versions of these pass permission flags that conflict with the above.
    alias cx='printf "\033[2J\033[3J\033[H"; and claude'
    alias cy='codex'
end
# END omarchy-settings: fish-config
