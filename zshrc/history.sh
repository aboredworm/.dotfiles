# history.sh
HISTSIZE=5000
if [[ "$OSTYPE" == darwin* ]]; then
  HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
else
  HISTFILE="${HISTFILE:-$HOME/.histfile}"
fi
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
