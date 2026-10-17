# Dotfiles

A regular Git repository for shared shell, terminal, editor, Pi, and desktop configuration. The installer links selected files into `$HOME`; it does not track the whole home directory.

## Install

On a fresh Mac, install Apple's Command Line Tools (`xcode-select --install`) and Homebrew, then:

```sh
git clone --branch macOS git@github.com:aboredworm/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --packages
```

Use `./install.sh` without `--packages` to link configuration only.

The installer chooses the macOS profile on macOS, the Arch Linux profile on Arch, and the common CLI profile elsewhere. Select a profile explicitly with `--profile macos`, `--profile archlinux`, or `--profile common`.

Existing files and directories that would be replaced are moved to a dated directory under `~/.dotfiles-backup/`. Re-running the installer is safe. Preview its actions with `./install.sh --dry-run`.

Package installation is opt-in:

```sh
./install.sh --packages
```

On macOS this runs Homebrew Bundle from `Brewfile` with `--no-upgrade`, then installs MiniLaunch and its font. Missing packages are installed, but already-installed packages are not broadly upgraded. The installer adds AeroSpace's tap and, on Homebrew versions with tap-trust controls, trusts only its named cask. Brewfile entries are not exact-version locks; Homebrew resolves current releases (versioned formula names such as `python@3.14` only constrain the major/minor line). Run `brew bundle upgrade --file=~/dotfiles/Brewfile` when you want to update them. On Arch it installs the listed pacman packages and prompts through `sudo`. Other Linux distributions get the common dotfiles only; install their dependencies separately.

## MiniLaunch

The macOS profile links your theme at `~/.config/minilaunch/config` and includes the normal, demo-cycle, and full-quit AeroSpace bindings. `--packages` also builds a pinned public MiniLaunch revision and installs its exact Noto Sans Mono ExtraCondensed Black font, verified by SHA-256. The font is downloaded separately; its license is in `assets/fonts/NotoSansMono-OFL.txt`.

To install just this component without the other packages:

```sh
./install.sh --profile macos --minilaunch
```

Development source stays in `~/projects/minilaunch`; the runtime goes in `~/.local/share/minilaunch`. Setup builds a pinned Git snapshot without resetting your development checkout. Re-running skips an unchanged install; a changed runtime is asked to quit before replacement. The pin is in `scripts/install-minilaunch.sh`.

Open AeroSpace and grant its Accessibility permission after installing it. Option+U shows/hides MiniLaunch, Option+Shift+U cycles demo styles, and Control+Option+Shift+U quits it. MiniLaunch starts on first use and stays resident; no login item or launch history is installed.

## Maintain

Edit the files in this repository or edit their symlinked copies in `$HOME`, then commit and push as usual. The installer never commits or pushes.

On another machine, update and re-link with:

```sh
./update.sh
```

`update.sh` uses `git pull --ff-only` and refuses to pull when the repository has uncommitted or untracked files. Use `./update.sh --no-pull` to re-link without fetching. Pass `--packages` if package changes should also be applied.

The GitHub repository is `git@github.com:aboredworm/.dotfiles.git`. The current branch is still named `macOS` to preserve the existing repository history. The old bare repositories in `$HOME` were left in place during migration.

## What is managed

- Zsh and Powerlevel10k, including portable startup scripts under `zshrc/`
- tmux and Neovim source config, with tmux session, background-window, and notes helpers
- Pi agent settings and `APPEND_SYSTEM.md`
- macOS AeroSpace, MiniLaunch, Alacritty, Ghostty, Karabiner, MPD/rmpc, and Homebrew configuration
- Existing Arch Hyprland, Waybar, Tofi, Alacritty, and VSCodium configuration under `platforms/archlinux/`

Neovim's source configuration is included. Its machine-local `.git`, virtualenv, mamba install, and Jupyter runtime are not copied or linked. If a machine already has a separate Git repo at `~/.config/nvim`, the installer leaves it untouched; otherwise it links the Neovim config files. Pi auth, model-store, sessions, package installs, and SSH credentials are excluded. The Arch media-server helper uses normal interactive `sudo` and does not read a password file.

Some settings remain machine-specific. The AeroSpace display toggle reads its UUID from `~/.config/aerospace/display-uuid`, which is excluded from Git. The `mount-nas` helper expects `NAS_HOST` and `NAS_EXPORT` to be set locally. Review the Hyprland monitor and wallpaper paths under `platforms/archlinux/.config/hypr/` when moving to Linux. The AeroSpace `Option+Shift+M` monitor toggle requires the free [`aspace` CLI](https://github.com/asumaran/aspace) at `~/.local/bin/aspace`. The Arch media-server helper accepts a device path as its argument and uses interactive `sudo`.
