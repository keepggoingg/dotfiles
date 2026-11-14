# Read by every zsh, including scripts. Keep it to cheap exports.
export EDITOR=nvim
export VISUAL=nvim
export PASSWORD_STORE_DIR="$HOME/dev/pass"
export SDKMAN_DIR="$HOME/.sdkman"
export FVM_CACHE_PATH="$HOME/.fvm"
export BUN_INSTALL="$HOME/.bun"

# uv, cargo
export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
