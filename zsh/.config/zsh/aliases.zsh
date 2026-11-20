# Nerd Font icons only where the terminal has the font (Ghostty/kitty, also inside tmux);
# terminals like the Claude desktop panel or VS Code would show empty boxes.
case "$TERM_PROGRAM" in
  claude-desktop|vscode|Apple_Terminal) export EZA_ICONS=never ;;
  *)                                    export EZA_ICONS=auto ;;
esac
alias ls='eza --group-directories-first --icons=$EZA_ICONS'
alias ll='eza -l --git --group-directories-first --icons=$EZA_ICONS'
alias la='eza -la --git --group-directories-first --icons=$EZA_ICONS'
alias lt='eza --tree --level=2 --icons=$EZA_ICONS'
alias cat='bat --paging=never --style=plain'
alias v='nvim'
alias lg='lazygit'
alias clear='pyroclear'
alias reload='exec zsh'

# Extract any archive: x file.tar.gz
x() {
  case "$1" in
    *.tar.gz|*.tgz)   tar xzf "$1" ;;
    *.tar.bz2|*.tbz2) tar xjf "$1" ;;
    *.tar.xz)         tar xJf "$1" ;;
    *.tar)            tar xf "$1" ;;
    *.zip|*.jar|*.apk|*.aar) unzip "$1" ;;
    *.gz)             gunzip "$1" ;;
    *.7z)             7z x "$1" ;;
    *) echo "x: don't know how to extract '$1'" >&2; return 1 ;;
  esac
}
alias t='tmux-sessionizer'

# Claude Code on the personal account (own login, memory, settings); plain `claude` stays on work.
alias claude-personal='CLAUDE_CONFIG_DIR=$HOME/.claude-personal claude'
