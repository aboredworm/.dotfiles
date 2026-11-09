source "$HOME/zshrc/init.sh"

for FILE in "$HOME"/zshrc/*.sh(N); do
  [[ "$FILE" == */init.sh ]] && continue
  source "$FILE"
done

# Keep workstation-only exports and secrets out of this repository.
[[ -r "$HOME/.local/priv/gemini_curl.sh" ]] && source "$HOME/.local/priv/gemini_curl.sh"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
