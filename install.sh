#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET_HOME="${DOTFILES_HOME:-$HOME}"
PROFILE=""
DRY_RUN=0
INSTALL_PACKAGES=0
BACKUP_ROOT="$TARGET_HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)-$$"

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --profile NAME   Select macos, archlinux, or common (default: detect OS)
  --packages       Install packages from Brewfile or platforms/archlinux/packages.txt
  --dry-run        Show links and backups without changing files
  -h, --help       Show this help
EOF
}

while (($#)); do
  case "$1" in
    --profile)
      [[ $# -ge 2 ]] || { echo "Missing profile after --profile" >&2; exit 2; }
      PROFILE="$2"
      shift 2
      ;;
    --packages)
      INSTALL_PACKAGES=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$PROFILE" ]]; then
  case "$(uname -s)" in
    Darwin) PROFILE=macos ;;
    Linux)
      if [[ -f /etc/arch-release ]]; then PROFILE=archlinux; else PROFILE=common; fi
      ;;
    *) PROFILE=common ;;
  esac
fi

case "$PROFILE" in
  macos|archlinux|common) ;;
  *) echo "Unknown profile: $PROFILE" >&2; exit 2 ;;
esac

link_item() {
  local source="$1" target="$2" relative="$3" backup

  if [[ ! -e "$source" ]]; then
    echo "Missing source: $source" >&2
    return 1
  fi

  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
    echo "Already linked: $target"
    return 0
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -e "$target" || -L "$target" ]]; then
      printf 'Would back up %s to %s\n' "$target" "$BACKUP_ROOT/$relative"
    fi
    printf 'Would link %s -> %s\n' "$target" "$source"
    return 0
  fi

  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    backup="$BACKUP_ROOT/$relative"
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    printf 'Backed up %s to %s\n' "$target" "$backup"
  fi
  ln -s "$source" "$target"
  printf 'Linked %s -> %s\n' "$target" "$source"
}

link_path() {
  local relative="$1"
  link_item "$REPO_DIR/$relative" "$TARGET_HOME/$relative" "$relative"
}

install_nvim_files() {
  local source relative
  if [[ -e "$TARGET_HOME/.config/nvim/.git" ]]; then
    echo "Skipping Neovim: $TARGET_HOME/.config/nvim is already a Git repository"
    return 0
  fi
  while IFS= read -r -d '' source; do
    relative="${source#"$REPO_DIR/"}"
    link_path "$relative"
  done < <(find "$REPO_DIR/.config/nvim" \
    \( -name .git -o -name .venv -o -name .local -o -name .jupyter -o -name __pycache__ \) -prune \
    -o -type f ! -name .nvimlog -print0)
}

install_packages() {
  case "$PROFILE" in
    macos)
      command -v brew >/dev/null 2>&1 || { echo "Homebrew is required for --packages" >&2; exit 1; }
      brew bundle install --no-upgrade --file="$REPO_DIR/Brewfile"
      ;;
    archlinux)
      command -v pacman >/dev/null 2>&1 || { echo "pacman is required for --packages" >&2; exit 1; }
      local -a packages=()
      while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" == \#* ]] || packages+=("$package")
      done < "$REPO_DIR/platforms/archlinux/packages.txt"
      ((${#packages[@]})) || return 0
      sudo pacman -S --needed "${packages[@]}"
      ;;
    common)
      echo "No package manifest for this OS. Install dependencies manually." >&2
      exit 1
      ;;
  esac
}

if [[ "$INSTALL_PACKAGES" -eq 1 ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Dry run: skipping package installation"
  else
    install_packages
  fi
fi

for path in \
  .zshrc \
  .p10k.zsh \
  .config/btop/btop.conf \
  .config/git/ignore \
  .config/tmux/tmux.conf \
  .local/bin/tmux-sessionizer \
  .local/bin/tmux-background \
  .local/bin/nvim-notes \
  .pi/agent/APPEND_SYSTEM.md \
  .pi/agent/settings.json; do
  link_path "$path"
done

link_item "$REPO_DIR/.config/tmux/tmux.conf" "$TARGET_HOME/.tmux.conf" ".tmux.conf"
link_path zshrc
install_nvim_files

case "$PROFILE" in
  macos)
    for path in \
      Brewfile \
      .config/aerospace/aerospace.toml \
      .config/aerospace/assign-startup-workspaces.sh \
      .config/alacritty/alacritty.toml \
      .config/ghostty/config.ghostty \
      .config/karabiner/karabiner.json \
      .config/mpd/mpd.conf \
      .config/rmpc/config.ron; do
      link_path "$path"
    done
    ;;
  archlinux)
    for path in \
      .config/alacritty/alacritty.toml \
      .config/hypr/hyprland.conf \
      .config/hypr/hyprpaper.conf \
      .config/hypr/hyprshade.toml \
      .config/tofi/config \
      .config/tofi/colors/colors \
      .config/tofi/colors/template.colors \
      .config/waybar/config.jsonc \
      .config/waybar/style.css \
      .config/VSCodium/User/settings.json \
      .local/bin/start-media-server; do
      link_item "$REPO_DIR/platforms/archlinux/$path" "$TARGET_HOME/$path" "platforms/archlinux/$path"
    done
    ;;
esac

printf 'Installed dotfiles profile: %s\n' "$PROFILE"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo 'Dry run complete; no files changed.'
fi
