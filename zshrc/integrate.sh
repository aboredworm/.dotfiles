if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  export _ZO_DOCTOR=0
  eval "$(zoxide init --cmd cd zsh)"
fi
