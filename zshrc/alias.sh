# Aliases
if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
else
  alias ls='ls --color=auto'
fi

alias vim='nvim'
alias c='clear'
alias rf='rm -r -f'
alias cdd='cd ..'
alias cddd='cd ../..'
alias python=python3
alias t='tmux-sessionizer'
alias mount-nas="sudo mkdir -p /Volumes/nas && sudo mount -t nfs -v -o resvport,nolocks,rw NAS_HOST:NAS_EXPORT /Volumes/nas"
alias conda='micromamba'
alias lg='lazygit'
alias g='git'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gsw='git switch'
alias gst='git stash'

# Run Git commands in this regular dotfiles repository.
alias dfc='git -C "$HOME/dotfiles"'
