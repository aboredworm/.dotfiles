#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
ROOT="$(mktemp -d)"
trap 'rm -rf "$ROOT"' EXIT

mkdir -p "$ROOT/bin"
export MOCK_SUDO_LOG="$ROOT/sudo.log" MOCK_PACMAN_LOG="$ROOT/pacman.log"
cat > "$ROOT/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$MOCK_SUDO_LOG"
if [[ "$1" == pacman ]]; then exec "$@"; fi
EOF
cat > "$ROOT/bin/pacman" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" >> "$MOCK_PACMAN_LOG"
EOF
for command in brew xcrun curl; do
  printf '#!/usr/bin/env bash\necho "Unexpected macOS command: %s" >&2\nexit 99\n' "$command" > "$ROOT/bin/$command"
done
chmod +x "$ROOT/bin/"*
export PATH="$ROOT/bin:$PATH"

for args in '--profile invalid' '--profile' '--unknown' '--profile archlinux --minilaunch'; do
  read -r -a options <<< "$args"
  if DOTFILES_HOME="$ROOT/invalid-home" "$REPO_DIR/install.sh" "${options[@]}" > "$ROOT/invalid.log" 2>&1; then
    echo "FAIL: accepted invalid options: $args" >&2
    exit 1
  fi
  [[ ! -e "$ROOT/invalid-home" ]]
done

DOTFILES_HOME="$ROOT/dry-home" "$REPO_DIR/install.sh" --profile archlinux --packages --dry-run > "$ROOT/dry.log"
[[ ! -e "$ROOT/dry-home" && ! -e "$MOCK_SUDO_LOG" && ! -e "$MOCK_PACMAN_LOG" ]]
grep -q 'platforms/archlinux/.config/hypr/nightlight.sh' "$ROOT/dry.log"
if grep -q 'MiniLaunch\|Brewfile\|aerospace' "$ROOT/dry.log"; then exit 1; fi

home="$ROOT/arch-home"
mkdir -p "$home/zshrc" "$home/.config/alacritty" "$home/.config/nvim/.venv"
printf 'old shell\n' > "$home/.zshrc"
printf 'local shell\n' > "$home/zshrc/local.sh"
printf 'old terminal\n' > "$home/.config/alacritty/alacritty.toml"
printf 'local runtime\n' > "$home/.config/nvim/.venv/keep"
ln -s "$ROOT/missing-prompt" "$home/.p10k.zsh"
DOTFILES_HOME="$home" "$REPO_DIR/install.sh" --profile archlinux > "$ROOT/install.log"
[[ ! -e "$MOCK_SUDO_LOG" && ! -e "$MOCK_PACMAN_LOG" ]]
[[ "$(readlink "$home/.zshrc")" == "$REPO_DIR/.zshrc" ]]
[[ "$(readlink "$home/zshrc")" == "$REPO_DIR/zshrc" ]]
[[ "$(readlink "$home/.config/alacritty/alacritty.toml")" == "$REPO_DIR/platforms/archlinux/.config/alacritty/alacritty.toml" ]]
[[ "$(readlink "$home/.tmux.conf")" == "$REPO_DIR/.config/tmux/tmux.conf" ]]
[[ -x "$home/.config/hypr/nightlight.sh" && -L "$home/.config/nvim/init.lua" ]]
grep -Fxq 'local runtime' "$home/.config/nvim/.venv/keep"
for path in Brewfile .config/aerospace .config/minilaunch .config/karabiner .config/ghostty .pi/agent/auth.json; do
  [[ ! -e "$home/$path" && ! -L "$home/$path" ]]
done
backups=("$home/.dotfiles-backup/"*)
[[ ${#backups[@]} -eq 1 ]]
backup="${backups[0]}"
grep -Fxq 'old shell' "$backup/.zshrc"
grep -Fxq 'local shell' "$backup/zshrc/local.sh"
grep -Fxq 'old terminal' "$backup/platforms/archlinux/.config/alacritty/alacritty.toml"
[[ "$(readlink "$backup/.p10k.zsh")" == "$ROOT/missing-prompt" ]]

DOTFILES_HOME="$home" "$REPO_DIR/install.sh" --profile archlinux > "$ROOT/repeat.log"
if grep -q '^Backed up' "$ROOT/repeat.log"; then exit 1; fi
backups=("$home/.dotfiles-backup/"*)
[[ ${#backups[@]} -eq 1 ]]

DOTFILES_HOME="$home" "$REPO_DIR/install.sh" --profile archlinux --packages > "$ROOT/packages.log"
[[ $(wc -l < "$MOCK_SUDO_LOG") -eq 1 ]]
expected=(-S --needed)
while IFS= read -r package || [[ -n "$package" ]]; do
  [[ -z "$package" || "$package" == \#* ]] || expected+=("$package")
done < "$REPO_DIR/platforms/archlinux/packages.txt"
printf '%s\n' "${expected[@]}" > "$ROOT/expected-packages"
cmp "$ROOT/expected-packages" "$MOCK_PACMAN_LOG"

for marker in directory file; do
  nvim_home="$ROOT/nvim-$marker-home"
  mkdir -p "$nvim_home/.config/nvim"
  if [[ "$marker" == directory ]]; then
    mkdir "$nvim_home/.config/nvim/.git"
  else
    printf 'gitdir: elsewhere\n' > "$nvim_home/.config/nvim/.git"
  fi
  printf 'independent editor\n' > "$nvim_home/.config/nvim/init.lua"
  DOTFILES_HOME="$nvim_home" "$REPO_DIR/install.sh" --profile common > "$ROOT/nvim-$marker.log"
  [[ ! -L "$nvim_home/.config/nvim/init.lua" ]]
  grep -Fxq 'independent editor' "$nvim_home/.config/nvim/init.lua"
  grep -q 'Skipping Neovim' "$ROOT/nvim-$marker.log"
  [[ ! -e "$nvim_home/.config/hypr" && ! -e "$nvim_home/.config/alacritty" ]]
done

DOTFILES_HOME="$ROOT/update-dry-home" "$REPO_DIR/update.sh" --no-pull --profile archlinux --dry-run > "$ROOT/update.log"
[[ ! -e "$ROOT/update-dry-home" ]]

if command -v zsh >/dev/null 2>&1; then
  env -u DOTFILES_DIR -u HISTFILE -u PNPM_HOME HOME="$home" EXPECTED_REPO="$REPO_DIR" \
    NAS_HOST=example.test NAS_EXPORT=/share NAS_MOUNT_POINT="$ROOT/nas" \
    zsh -dfc '
      source "$HOME/zshrc/alias.sh"
      [[ "$DOTFILES_DIR" == "$EXPECTED_REPO" ]] || exit 1
      [[ "$(dfc rev-parse --show-toplevel)" == "$EXPECTED_REPO" ]] || exit 1
      OSTYPE=linux-gnu
      source "$HOME/zshrc/pnpm.sh"
      source "$HOME/zshrc/history.sh"
      [[ "$PNPM_HOME" == "$HOME/.local/share/pnpm" && "$HISTFILE" == "$HOME/.histfile" ]] || exit 1
      mount_nas
    '
  grep -Fxq "mount -t nfs example.test:/share $ROOT/nas" "$MOCK_SUDO_LOG"
fi
printf 'Arch tests passed: validation, dry-run, backups, repeat installs, profile isolation, opt-in packages, Neovim preservation, shell paths.\n'
