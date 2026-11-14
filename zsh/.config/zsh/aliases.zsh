alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -l --git --group-directories-first --icons=auto'
alias la='eza -la --git --group-directories-first --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
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
