# dotfiles (macOS)

kitty + zsh + tmux + Neovim, linked into `$HOME` with GNU stow. The old Arch/sway
setup lives on the `arch` branch.

## Install on a new Mac

```bash
git clone git@github.com:endo000/dotfiles.git ~/dev/personal/dotfiles
~/dev/personal/dotfiles/install.sh
```

`install.sh` runs `brew bundle`, installs SDKMAN and oh-my-tmux, moves any
conflicting files to `~/.dotfiles-backup/<date>/` and stows every package.

## Layout

Each top-level folder is a stow package mirroring `$HOME`:

| package  | what                                                      |
|----------|-----------------------------------------------------------|
| zsh      | `.zshenv`, `.zprofile` (PATH), `.zshrc`, `.config/zsh/`   |
| kitty    | `.config/kitty/kitty.conf`                                |
| tmux     | `.config/tmux/tmux.conf.local` (on top of oh-my-tmux)     |
| nvim     | `.config/nvim` (LazyVim)                                  |
| ideavim  | `.ideavimrc`                                              |
| starship | `.config/starship.toml`                                   |
| git      | `.gitconfig`, `.config/git/ignore`                        |
| direnv   | `.config/direnv/direnv.toml`                              |

Add a package: create `<pkg>/<path as in $HOME>`, then
`stow --target ~ <pkg>` from the repo root.

## zsh notes

- Plugins: antidote, list in `zsh/.config/zsh/plugins.txt`. Updates only on
  `antidote update`.
- SDKMAN is not sourced at startup; its `current` Java/Maven are on PATH and
  `sdk` loads it on first use.
- Machine-only settings and secrets go in `~/.zshrc.local` (not in the repo).
- Keys: `Ctrl-R` history, `Ctrl-T` files, `Alt-C` dirs (fzf), `Ctrl-Y` accept
  suggestion, `z`/`zi` jump (zoxide).
