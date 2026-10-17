#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT

DOTFILES_HOME="$ROOT/dry-home" "$REPO_DIR/install.sh" --profile macos --minilaunch --dry-run > "$ROOT/dry.log"
[[ ! -e "$ROOT/dry-home" ]]
grep -q '.config/minilaunch/config' "$ROOT/dry.log"
grep -q 'Would install MiniLaunch revision' "$ROOT/dry.log"
DOTFILES_HOME="$ROOT/packages-home" "$REPO_DIR/install.sh" --profile macos --packages --dry-run > "$ROOT/packages-dry.log"
[[ ! -e "$ROOT/packages-home" ]]
grep -q 'Would install MiniLaunch revision' "$ROOT/packages-dry.log"
if DOTFILES_HOME="$ROOT/common-home" "$REPO_DIR/install.sh" --profile common --minilaunch > "$ROOT/error.log" 2>&1; then
  echo 'FAIL: accepted MiniLaunch for a non-macOS profile.' >&2
  exit 1
fi
[[ ! -e "$ROOT/common-home" ]]
DOTFILES_HOME="$ROOT/common-dry-home" "$REPO_DIR/install.sh" --profile common --dry-run > "$ROOT/common.log"
if grep -q 'Would install MiniLaunch revision' "$ROOT/common.log"; then exit 1; fi

fixture="$ROOT/repo"
mkdir -p "$fixture/scripts" "$ROOT/bin"
cp "$REPO_DIR/install.sh" "$fixture/"
for path in .zshrc .p10k.zsh .config .pi .local zshrc Brewfile; do ln -s "$REPO_DIR/$path" "$fixture/$path"; done
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" "$*" >> "$MOCK_BREW_LOG"' \
  'if [[ "$1" == command && "${MOCK_TRUST:-1}" == 0 ]]; then exit 1; fi' > "$ROOT/bin/brew"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" "$*" >> "$MOCK_MINILAUNCH_LOG"' > "$fixture/scripts/install-minilaunch.sh"
chmod +x "$ROOT/bin/brew" "$fixture/scripts/install-minilaunch.sh"
export MOCK_BREW_LOG="$ROOT/brew.log" MOCK_MINILAUNCH_LOG="$ROOT/minilaunch.log"
for mode in modern legacy; do
  home="$ROOT/$mode-home"
  mkdir -p "$home/.config/nvim/.git"
  : > "$MOCK_BREW_LOG"
  : > "$MOCK_MINILAUNCH_LOG"
  trust=1
  [[ "$mode" != legacy ]] || trust=0
  PATH="$ROOT/bin:$PATH" MOCK_TRUST="$trust" DOTFILES_HOME="$home" \
    "$fixture/install.sh" --profile macos --packages > "$ROOT/$mode.log"
  grep -Fxq 'tap nikitabobko/tap' "$MOCK_BREW_LOG"
  grep -q '^bundle install --no-upgrade --file=' "$MOCK_BREW_LOG"
  [[ $(wc -l < "$MOCK_MINILAUNCH_LOG") -eq 1 ]]
  if [[ "$mode" == modern ]]; then
    grep -Fxq 'trust --cask nikitabobko/tap/aerospace' "$MOCK_BREW_LOG"
  elif grep -q '^trust ' "$MOCK_BREW_LOG"; then exit 1; fi
  [[ -L "$home/.config/minilaunch/config" ]]
done

mkdir -p "$ROOT/font-home/projects/minilaunch"
printf '%s\n' '#!/bin/bash' 'echo Darwin' > "$ROOT/bin/uname"
printf '%s\n' '#!/bin/bash' 'exit 0' > "$ROOT/bin/xcrun"
printf '%s\n' '#!/bin/bash' \
  'if [[ "$3" == rev-parse && "$4" == --show-toplevel ]]; then (cd "$2" && pwd -P);' \
  'elif [[ "$3" == rev-parse ]]; then printf "%s\n" "${4:0:40}"; fi' > "$ROOT/bin/git"
printf '%s\n' '#!/bin/bash' \
  'while (($#)); do if [[ "$1" == -o ]]; then printf "wrong font" > "$2"; exit 0; fi; shift; done' > "$ROOT/bin/curl"
chmod +x "$ROOT/bin/uname" "$ROOT/bin/xcrun" "$ROOT/bin/git" "$ROOT/bin/curl"
if PATH="$ROOT/bin:$PATH" DOTFILES_HOME="$ROOT/font-home" \
    "$REPO_DIR/scripts/install-minilaunch.sh" > "$ROOT/font.log" 2>&1; then
  echo 'FAIL: accepted a font with the wrong checksum.' >&2
  exit 1
fi
grep -q 'Font checksum mismatch' "$ROOT/font.log"
[[ ! -e "$ROOT/font-home/Library/Fonts/NotoSansMono-ExtraCondensedBlack.ttf" ]]
[[ ! -e "$ROOT/font-home/.local/share/minilaunch" ]]
printf 'Bootstrap tests passed: dry-run, profile isolation, package integration, scoped tap trust, config links, font verification.\n'
