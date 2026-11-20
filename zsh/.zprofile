# Login shells (Ghostty, kitty and tmux start these). PATH lives here because macOS
# /etc/zprofile reorders PATH after .zshenv.
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
eval "$(rbenv init - --no-rehash zsh)"

# python.org builds; python3 resolves to 3.12 like before.
path=(/Library/Frameworks/Python.framework/Versions/{3.12,3.10,3.14}/bin(N) $path)

# Java and Maven from SDKMAN without running sdkman-init (`sdk` loads it on demand).
export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
path=($SDKMAN_DIR/candidates/*/current/bin(N) $path)

# Flutter (fvm global), pub tools, adb, bun
path=(
  $HOME/.fvm/default/bin
  $HOME/.pub-cache/bin
  $HOME/Library/Android/sdk/platform-tools
  $BUN_INSTALL/bin
  /Applications/Ghostty.app/Contents/MacOS # ghostty CLI (+show-config, +validate-config)
  /Applications/kitty.app/Contents/MacOS   # kitty, kitten
  $path
)
typeset -U path
