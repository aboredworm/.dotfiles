if [[ -x /opt/homebrew/bin/brew ]]; then
  if [[ ${HOMEBREW_PREFIX:-} != /opt/homebrew || ":$PATH:" != *:/opt/homebrew/bin:* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  if [[ ${HOMEBREW_PREFIX:-} != /home/linuxbrew/.linuxbrew || ":$PATH:" != *:/home/linuxbrew/.linuxbrew/bin:* ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
elif command -v brew >/dev/null 2>&1; then
  if [[ -z ${HOMEBREW_PREFIX:-} || ":$PATH:" != *:"${HOMEBREW_PREFIX}/bin":* ]]; then
    eval "$(brew shellenv)"
  fi
fi
