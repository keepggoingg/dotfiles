-- "Open in Neovim.app": Finder's Open With target for any file or folder.
-- Hands each item to ~/.local/bin/term-open (nvim in tmux, inside Ghostty).
-- Built into ~/Applications by install.sh (osacompile).
on open theItems
	repeat with f in theItems
		do shell script "$HOME/.local/bin/term-open " & quoted form of POSIX path of f & " >/dev/null 2>&1 &"
	end repeat
end open

on run
	tell application "Ghostty" to activate
end run
