# ---- Options -----------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt extended_history share_history hist_ignore_all_dups hist_ignore_space \
       hist_reduce_blanks hist_verify
setopt auto_cd auto_pushd pushd_ignore_dups pushd_silent interactive_comments
setopt extended_glob no_beep
bindkey -e

# ---- Completion (dump rebuilt once a day, otherwise -C for speed) -------------
mkdir -p "$HOME/.cache/zsh"
# /usr/local/share/zsh is a group-writable leftover of Intel Homebrew; compinit refuses it.
fpath=(${fpath:#/usr/local/share/zsh/*})
autoload -Uz compinit
_zcd="$HOME/.cache/zsh/zcompdump"
if [[ -n $_zcd(#qN.mh+24) || ! -f $_zcd ]]; then compinit -d "$_zcd"; else compinit -C -d "$_zcd"; fi
unset _zcd
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:(cd|z|__zoxide_z):*' fzf-preview 'eza -1 --color=always --icons=${EZA_ICONS/auto/always} $realpath'

# ---- Plugins (antidote; `antidote update` to upgrade, never automatic) --------
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load "$HOME/.config/zsh/plugins.txt" "$HOME/.cache/zsh/plugins.zsh"
bindkey '^y' autosuggest-accept

# ---- Tools ---------------------------------------------------------------------
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range :300 {}'"
source <(fzf --zsh)            # Ctrl-R history, Ctrl-T files, Alt-C dirs
eval "$(zoxide init zsh)"      # z <dir>, zi = interactive
eval "$(direnv hook zsh)"

export BAT_THEME=ansi          # follows the kitty palette
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# SDKMAN is heavy; load it only when `sdk` is called.
sdk() { unfunction sdk; source "$SDKMAN_DIR/bin/sdkman-init.sh"; sdk "$@"; }

[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && source "$HOME/.dart-cli-completion/zsh-config.zsh"

source "$HOME/.config/zsh/aliases.zsh"
source "$HOME/.config/zsh/ssh.zsh"

# ---- Arrow keys: Normal (^[[A) and Application (^[OA) modes -------------------
# Prefix history search on Up/Down in both forms, and leave Application Keypad
# Mode before each prompt (a crashed TUI can leave it on).
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search add-zsh-hook
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
for _km in emacs viins vicmd; do
  bindkey -M $_km '^[[A' up-line-or-beginning-search
  bindkey -M $_km '^[OA' up-line-or-beginning-search
  bindkey -M $_km '^[[B' down-line-or-beginning-search
  bindkey -M $_km '^[OB' down-line-or-beginning-search
done
unset _km
_reset_keypad_mode() { echoti rmkx 2>/dev/null }
add-zsh-hook precmd _reset_keypad_mode

# Machine-only settings and secrets (not in the repo).
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

eval "$(starship init zsh)"
