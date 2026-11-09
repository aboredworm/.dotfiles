# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
if [[ -n "${LS_COLORS:-}" ]]; then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi
zstyle ':completion:*' menu no

if [[ "$OSTYPE" == darwin* ]]; then
  LS_PREVIEW='ls -G'
else
  LS_PREVIEW='ls --color=auto'
fi
zstyle ':fzf-tab:complete:cd:*' fzf-preview "$LS_PREVIEW $realpath"
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview "$LS_PREVIEW $realpath"
