#!/usr/bin/env bash
# Bootstrap a Mac from this repo. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"
DOTFILES="$PWD"
PACKAGES=(zsh kitty tmux nvim ideavim starship git direnv bin)

if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
brew bundle --file="$DOTFILES/Brewfile" || echo "brew bundle had failures (often casks already installed by hand); continuing"

# Java/Maven via SDKMAN (the shell only puts its current versions on PATH)
[[ -d "$HOME/.sdkman" ]] || curl -s "https://get.sdkman.io?rcupdate=false" | bash

# tmux plugin manager; plugins are installed after stow below
if [[ ! -d "$HOME/.config/tmux/plugins/tpm" ]]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
fi

# Move real files that would block stow into a dated backup, then link.
# Only files are moved; existing directories are left for stow to link into.
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES/$pkg/"}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      mkdir -p "$backup/$(dirname "$rel")"
      mv "$target" "$backup/$rel"
      echo "backed up ~/$rel"
    fi
  done < <(find "$DOTFILES/$pkg" -type f -print0)
done
stow --dir "$DOTFILES" --target "$HOME" --restow "${PACKAGES[@]}"

[[ -f "$HOME/.z" ]] && command -v zoxide >/dev/null && zoxide import z --merge || true
"$HOME/.config/tmux/plugins/tpm/bin/install_plugins" || true
echo "Done. Open a new terminal."
