#!/usr/bin/env bash
# Bootstrap a Mac from this repo. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")"
DOTFILES="$PWD"
PACKAGES=(zsh kitty ghostty fastfetch btop tmux nvim ideavim starship git direnv bin ssh claude)

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

mkdir -p "$HOME/.ssh/cm" "$HOME/.ssh/config.d" && chmod 700 "$HOME/.ssh" "$HOME/.ssh/cm" "$HOME/.ssh/config.d"

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
# Generated colour files for Ghostty/tmux/btop (Tokyo Night Deep until you pick another look).
"$HOME/.local/bin/looks" restore --no-reload || true

# Private half of the Claude Code setup (memory, settings, plugin kits), if this account can read it.
CLAUDE_PRIVATE="$HOME/dev/personal/claude-private"
if [[ ! -d "$CLAUDE_PRIVATE" ]] && command -v gh >/dev/null && gh repo view keepggoingg/claude-private >/dev/null 2>&1; then
  git clone git@github.com:keepggoingg/claude-private.git "$CLAUDE_PRIVATE"
fi
[[ -x "$CLAUDE_PRIVATE/bin/restore" ]] && "$CLAUDE_PRIVATE/bin/restore" || true

# GitHub profile README with the Claude Code hours card; its ledger lives in the repo, so
# the count carries over. The LaunchAgent updates and pushes it daily at 22:00.
PROFILE="$HOME/dev/personal/keepggoingg"
[[ -d "$PROFILE" ]] || git clone git@github.com:keepggoingg/keepggoingg.git "$PROFILE" || true
[[ -x "$PROFILE/scripts/install-launchagent.sh" ]] && "$PROFILE/scripts/install-launchagent.sh" || true

[[ -f "$HOME/.z" ]] && command -v zoxide >/dev/null && zoxide import z --merge || true
"$HOME/.config/tmux/plugins/tpm/bin/install_plugins" || true
"$DOTFILES/macos/build-open-in-neovim.sh" || echo "Open in Neovim.app build failed; continuing"
echo "Done. Open a new terminal."
