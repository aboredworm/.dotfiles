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
mount_nas() {
  : "${NAS_HOST:?Set NAS_HOST before mounting the NAS}"
  : "${NAS_EXPORT:?Set NAS_EXPORT before mounting the NAS}"
  local mount_point="${NAS_MOUNT_POINT:-/mnt/nas}"
  if [[ "$OSTYPE" == darwin* ]]; then
    mount_point="${NAS_MOUNT_POINT:-/Volumes/nas}"
    sudo mkdir -p "$mount_point"
    sudo mount -t nfs -v -o resvport,nolocks,rw "${NAS_HOST}:${NAS_EXPORT}" "$mount_point"
  else
    sudo mkdir -p "$mount_point"
    sudo mount -t nfs "${NAS_HOST}:${NAS_EXPORT}" "$mount_point"
  fi
}
alias mount-nas=mount_nas
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

# Resolve the checkout through ~/zshrc's symlink, including non-default locations.
export DOTFILES_DIR="${DOTFILES_DIR:-${${(%):-%x}:A:h:h}}"
function dfc() {
  git -C "$DOTFILES_DIR" "$@"
}
