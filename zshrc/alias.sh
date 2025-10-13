# alias.sh
# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias rf='rm -r -f'
alias cdd='cd ..'
alias cddd='cd ../..'
alias python=python3
alias t='tmux-sessionizer'
alias mount-nas="sudo mkdir /Volumes/nas && sudo mount -t nfs -v -o resvport,nolocks,rw NAS_HOST:NAS_EXPORT /Volumes/nas"
alias conda="micromamba"

# Dotfile git setup
alias dfc='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

