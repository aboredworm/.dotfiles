#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TARGET_HOME="${DOTFILES_HOME:-$HOME}"
REVISION="5e0f47de2e1fa81461dc799e16820fb4aea3a689"
REMOTE="https://github.com/aboredworm/minilaunch.git"
FONT_URL="https://raw.githubusercontent.com/notofonts/noto-fonts/326a408bd3657d082c9af9ebd63e9e1bed599d10/hinted/ttf/NotoSansMono/NotoSansMono-ExtraCondensedBlack.ttf"
FONT_SHA256="be1d5111e5d8d16773e26f36237d9adec4996670164946df106f0c0ccfa17e3e"

if [[ "${1:-}" == --dry-run && $# -eq 1 ]]; then
  printf 'Would install MiniLaunch revision %s from %s\n' "$REVISION" "$REMOTE"
  printf 'Would keep development source in %s/projects/minilaunch\n' "$TARGET_HOME"
  printf 'Would install the runtime in %s/.local/share/minilaunch\n' "$TARGET_HOME"
  printf 'Would install the verified Noto font in %s/Library/Fonts\n' "$TARGET_HOME"
  exit 0
fi
if (($#)); then
  echo 'Usage: scripts/install-minilaunch.sh [--dry-run]' >&2
  exit 2
fi
[[ "$(uname -s)" == Darwin ]] || { echo 'MiniLaunch requires macOS.' >&2; exit 1; }
xcrun --find clang >/dev/null 2>&1 || {
  echo 'Install Xcode Command Line Tools with xcode-select --install, then rerun.' >&2
  exit 1
}
xcrun --sdk macosx --show-sdk-path >/dev/null

mkdir -p "$TARGET_HOME"
TARGET_HOME="$(cd "$TARGET_HOME" && pwd -P)"
SOURCE="$TARGET_HOME/projects/minilaunch"
RUNTIME="$TARGET_HOME/.local/share/minilaunch"
FONT_DIR="$TARGET_HOME/Library/Fonts"
BACKUP_ROOT="${DOTFILES_BACKUP_ROOT:-$TARGET_HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-$$}"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-minilaunch.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

if [[ -e "$SOURCE" || -L "$SOURCE" ]]; then
  root="$(git -C "$SOURCE" rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Refusing to replace non-Git directory: $SOURCE" >&2
    exit 1
  }
  [[ "$root" == "$(cd "$SOURCE" && pwd -P)" ]] || {
    echo "Expected a separate Git checkout at $SOURCE" >&2
    exit 1
  }
else
  mkdir -p "$(dirname "$SOURCE")"
  git clone --branch main "$REMOTE" "$SOURCE"
fi
if ! git -C "$SOURCE" cat-file -e "$REVISION^{commit}" 2>/dev/null; then
  origin="$(git -C "$SOURCE" remote get-url origin)"
  case "$origin" in
    https://github.com/aboredworm/minilaunch|https://github.com/aboredworm/minilaunch.git|git@github.com:aboredworm/minilaunch|git@github.com:aboredworm/minilaunch.git) ;;
    *) echo "Refusing to modify an unrelated checkout: $SOURCE" >&2; exit 1 ;;
  esac
  git -C "$SOURCE" fetch --no-tags "$REMOTE" "$REVISION"
fi
[[ "$(git -C "$SOURCE" rev-parse "$REVISION^{commit}")" == "$REVISION" ]] || exit 1

backup_file() {
  local target="$1" relative="$2"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$(dirname "$BACKUP_ROOT/$relative")"
    mv "$target" "$BACKUP_ROOT/$relative"
    printf 'Backed up %s to %s\n' "$target" "$BACKUP_ROOT/$relative"
  fi
}

font="$FONT_DIR/NotoSansMono-ExtraCondensedBlack.ttf"
actual=""
if [[ -f "$font" ]]; then actual="$(/usr/bin/shasum -a 256 "$font")"; actual="${actual%% *}"; fi
if [[ "$actual" != "$FONT_SHA256" ]]; then
  curl --fail --location --silent --show-error --retry 2 --connect-timeout 15 --max-time 120 \
    "$FONT_URL" -o "$WORK_DIR/font.ttf"
  actual="$(/usr/bin/shasum -a 256 "$WORK_DIR/font.ttf")"
  [[ "${actual%% *}" == "$FONT_SHA256" ]] || { echo 'Font checksum mismatch; not installing.' >&2; exit 1; }
  mkdir -p "$FONT_DIR"
  backup_file "$font" "Library/Fonts/NotoSansMono-ExtraCondensedBlack.ttf"
  /usr/bin/install -m 644 "$WORK_DIR/font.ttf" "$font"
fi
license="$FONT_DIR/NotoSansMono-OFL.txt"
if ! cmp -s "$REPO_DIR/assets/fonts/NotoSansMono-OFL.txt" "$license"; then
  mkdir -p "$FONT_DIR"
  backup_file "$license" "Library/Fonts/NotoSansMono-OFL.txt"
  /usr/bin/install -m 644 "$REPO_DIR/assets/fonts/NotoSansMono-OFL.txt" "$license"
fi

if [[ -f "$RUNTIME/.dotfiles-version" && -f "$RUNTIME/.dotfiles-manifest.sha256" ]] &&
    [[ "$(< "$RUNTIME/.dotfiles-version")" == "$REVISION" ]] &&
    (cd "$RUNTIME" && /usr/bin/shasum -a 256 -c .dotfiles-manifest.sha256 >/dev/null 2>&1); then
  echo 'MiniLaunch is already installed at the pinned version.'
  exit 0
fi

mkdir "$WORK_DIR/source"
git -C "$SOURCE" archive "$REVISION" | tar -xf - -C "$WORK_DIR/source"
(cd "$WORK_DIR/source" && ./build.sh)
same=1
for file in Contents/Info.plist Contents/MacOS/MiniLaunch; do
  cmp -s "$WORK_DIR/source/build/MiniLaunch.app/$file" "$RUNTIME/MiniLaunch.app/$file" || same=0
done
for file in toggle.sh demo-toggle.sh quit.sh styles/default.conf styles/warm.conf styles/electric.conf styles/paper.conf; do
  cmp -s "$WORK_DIR/source/$file" "$RUNTIME/$file" || same=0
done
if [[ "$same" -eq 0 ]]; then
  if [[ -x "$RUNTIME/quit.sh" ]]; then "$RUNTIME/quit.sh"; fi
  (cd "$WORK_DIR/source" && HOME="$TARGET_HOME" ./install.sh)
else
  echo 'Existing MiniLaunch runtime matches the pinned build.'
fi
printf '%s\n' "$REVISION" > "$WORK_DIR/version"
(cd "$RUNTIME" && /usr/bin/shasum -a 256 \
  MiniLaunch.app/Contents/Info.plist MiniLaunch.app/Contents/MacOS/MiniLaunch \
  toggle.sh demo-toggle.sh quit.sh styles/default.conf styles/warm.conf styles/electric.conf styles/paper.conf) > "$WORK_DIR/manifest"
mv "$WORK_DIR/manifest" "$RUNTIME/.dotfiles-manifest.sha256"
mv "$WORK_DIR/version" "$RUNTIME/.dotfiles-version"
printf 'MiniLaunch installed from pinned revision %s\n' "$REVISION"
