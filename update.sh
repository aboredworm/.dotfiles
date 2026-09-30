#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PULL=1
INSTALL_ARGS=()

while (($#)); do
  case "$1" in
    --no-pull)
      PULL=0
      shift
      ;;
    *)
      INSTALL_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ "$PULL" -eq 1 ]]; then
  if ! git -C "$REPO_DIR" diff --quiet || ! git -C "$REPO_DIR" diff --cached --quiet || [[ -n "$(git -C "$REPO_DIR" ls-files --others --exclude-standard)" ]]; then
    echo "Refusing to pull with local changes. Commit or stash them first, or use --no-pull." >&2
    exit 1
  fi
  git -C "$REPO_DIR" pull --ff-only
fi

if ((${#INSTALL_ARGS[@]})); then
  exec "$REPO_DIR/install.sh" "${INSTALL_ARGS[@]}"
else
  exec "$REPO_DIR/install.sh"
fi
