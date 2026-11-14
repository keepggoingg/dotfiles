# s [name] [ssh args]: connect to an SSH target stored in pass.
# Entries are any pass path containing /ssh/, whose first line is the ssh
# arguments (user@host, optionally -p/-i/-J ...). `s` alone opens a picker;
# `s fit` or `s ald/prod` matches by the end of the path.
_pass_ssh_entries() {
  (cd "$PASSWORD_STORE_DIR" && fd --extension gpg . | sed 's/\.gpg$//' | grep '/ssh/' | sort)
}

s() {
  local entry=$1
  if [[ -z $entry ]]; then
    entry=$(_pass_ssh_entries | fzf --prompt 'ssh> ' --height 40% --reverse) || return
  elif [[ ! -f $PASSWORD_STORE_DIR/$entry.gpg ]]; then
    entry=$(_pass_ssh_entries | grep -E -m1 "(^|/)${entry}\$") || { print -u2 "s: no pass entry ends with '$1'"; return 1; }
  fi
  local line; line=$(pass show "$entry" | head -1) || return
  local -a args=("${(@Q)${(z)line}}")
  args=("${args[@]/#\~/$HOME}")
  [[ -n $TMUX ]] && tmux rename-window "${entry:t}"
  ssh "${args[@]}" "${@:2}"
  [[ -n $TMUX ]] && tmux set-option -wu automatic-rename
}

_s() { compadd -- ${(f)"$(_pass_ssh_entries)"} }
compdef _s s
