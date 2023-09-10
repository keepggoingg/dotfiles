# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
zmodload zsh/zprof

typeset -U path cdpath fpath manpath

HELPDIR="/usr/share/zsh/$ZSH_VERSION/help"

# Use emacs keymap as the default.
bindkey -e

autoload -Uz compinit && compinit
# autoload -Uz compinit promptinit
# compinit
# promptinit

# eval "$(zoxide init zsh)"
eval "$(lua /usr/share/z.lua/z.lua --init zsh)"
eval "$(direnv hook zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

[[ ! -f ${ZDOTDIR}/.p10k.zsh ]] || source ${ZDOTDIR}/.p10k.zsh

## home-manager/antidote begin :
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# History options should be set in .zshrc and after oh-my-zsh sourcing.
# See https://github.com/nix-community/home-manager/issues/177.
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="${HOME}/.local/share/zsh/zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

setopt NO_NOMATCH
setopt noglob


if [[ $options[zle] = on ]]; then
  . /usr/share/fzf/completion.zsh
  . /usr/share/fzf/key-bindings.zsh
fi

function gitconfig() {
  git config user.name "$(pass show "$1"/credentials/name)"
  git config user.email "$(pass show "$1"/credentials/email)"
}

function sshpi() {
  ssh $(pass show personal/hostnames/pi)
}

function sshres() {
  ssh $(pass show result/ssh/coci/"$1")
}

function vpnres() {
  CONFIG_FOLDER="/home/aleksandr/.config/vpn"
  VPN_FOLDER="$CONFIG_FOLDER"/result
  PASS_FILE="$VPN_FOLDER"/pass.txt 
  if [[ ! -f "$PASS_FILE" ]]; then
    echo "create pass.txt"
    pass show result/vpn/username >> "$PASS_FILE"
    pass show result/vpn/password >> "$PASS_FILE"
  fi
  sudo openvpn --config "$VPN_FOLDER"/result.ovpn \
    --auth-user-pass "$PASS_FILE" \
    --script-security 2 \
    --up /etc/openvpn/update-resolv-conf \
    --down /etc/openvpn/update-resolv-conf \
    --down-pre
  unset PASS_FILE
  unset VPN_FOLDER
  unset CONFIG_FOLDER
}

function vpnlabex() {
  CONFIG_FOLDER="/home/aleksandr/.config/vpn"
  VPN_FOLDER="$CONFIG_FOLDER"/labex
  PASS_FILE="$VPN_FOLDER"/pass.txt 
  if [[ ! -f "$PASS_FILE" ]]; then
    echo "create pass.txt"
    echo "host =" $(pass show result/labex/vpn/host) >> "$PASS_FILE"
    echo "username =" $(pass show result/labex/vpn/username) >> "$PASS_FILE"
    echo "password =" $(pass show result/labex/vpn/password) >> "$PASS_FILE"
  fi
  sudo openfortivpn -c $PASS_FILE
  unset PASS_FILE
  unset VPN_FOLDER
  unset CONFIG_FOLDER
}

if test -n "$KITTY_INSTALLATION_DIR"; then
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Aliases

alias emu='QT_QPA_PLATFORM=xcb emulator -avd "Pixel_6_API_28" -writable-system'
alias f='fvm flutter'

alias exa='exa '\''--icons'\'''
alias la='exa -a'
alias ll='exa -l'
alias lla='exa -la'
alias ls='exa'
alias lt='exa --tree'

alias vim="nvim"
alias vi="nvim"
alias vimdiff='nvim -d'

if [[ "$TERM" = "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
  alias icat="kitty +kitten icat"
  alias diff="kitty +kitten diff"
fi
