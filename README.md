# dotfiles (macOS)

kitty + zsh + tmux + Neovim, linked into `$HOME` with GNU stow. The old Arch/sway
setup lives on the `arch` branch.

## Install on a new Mac

```bash
git clone git@github.com:endo000/dotfiles.git ~/dev/personal/dotfiles
~/dev/personal/dotfiles/install.sh
```

`install.sh` runs `brew bundle`, installs SDKMAN, TPM and tmux plugins, moves any
conflicting files to `~/.dotfiles-backup/<date>/` and stows every package.

## Layout

Each top-level folder is a stow package mirroring `$HOME`:

| package  | what                                                      |
|----------|-----------------------------------------------------------|
| zsh      | `.zshenv`, `.zprofile` (PATH), `.zshrc`, `.config/zsh/`   |
| kitty    | `.config/kitty/kitty.conf`                                |
| tmux     | `.config/tmux/tmux.conf` (own config, TPM plugins)        |
| nvim     | `.config/nvim` (LazyVim)                                  |
| ideavim  | `.ideavimrc`                                              |
| starship | `.config/starship.toml`                                   |
| git      | `.gitconfig`, `.config/git/ignore`                        |
| direnv   | `.config/direnv/direnv.toml`                              |
| bin      | `.local/bin/` scripts (`tmux-sessionizer`)                |

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

## tmux notes

Prefix is `Ctrl-Space`. `prefix r` reloads, `prefix I` installs plugins.

| keys | action |
|------|--------|
| `prefix f` / `t` in zsh | pick a repo under `~/dev`, switch to its session |
| `prefix s` / `Shift-Tab` | session list / last session |
| `prefix -` / `_` (or `"` / `%`, `\|`) | split below / right, same folder |
| `Ctrl-h/j/k/l` | move between tmux panes and nvim splits |
| `prefix +` | zoom pane |
| `prefix g` | lazygit popup |
| `prefix Enter`, `v`, `y` | copy mode, select, copy to macOS clipboard |
| `prefix C-s` / `C-r` | save / restore sessions (also autosaved every 15 min) |
