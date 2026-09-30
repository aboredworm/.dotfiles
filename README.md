# Dotfiles

A regular Git repository for shared shell, terminal, editor, Pi, and desktop configuration. The installer links selected files into `$HOME`; it does not track the whole home directory.

## Install

Clone the `macOS` branch and run the installer:

```sh
git clone --branch macOS git@github.com:moore-andrew05/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer chooses the macOS profile on macOS, the Arch Linux profile on Arch, and the common CLI profile elsewhere. Select a profile explicitly with `--profile macos`, `--profile archlinux`, or `--profile common`.

Existing files and directories that would be replaced are moved to a dated directory under `~/.dotfiles-backup/`. Re-running the installer is safe. Preview its actions with `./install.sh --dry-run`.

Package installation is opt-in:

```sh
./install.sh --packages
```

On macOS this runs Homebrew Bundle from `Brewfile` with `--no-upgrade`: missing packages are installed, but already-installed packages are not broadly upgraded. Brewfile entries are not exact-version locks; Homebrew resolves current releases (versioned formula names such as `python@3.14` only constrain the major/minor line). Run `brew bundle upgrade --file=~/dotfiles/Brewfile` when you want to update them. On Arch it installs the listed pacman packages and prompts through `sudo`. Other Linux distributions get the common dotfiles only; install their dependencies separately.

## Maintain

Edit the files in this repository or edit their symlinked copies in `$HOME`, then commit and push as usual. The installer never commits or pushes.

On another machine, update and re-link with:

```sh
./update.sh
```

`update.sh` uses `git pull --ff-only` and refuses to pull when the repository has uncommitted or untracked files. Use `./update.sh --no-pull` to re-link without fetching. Pass `--packages` if package changes should also be applied.

The existing remote is `git@github.com:moore-andrew05/.dotfiles.git`. The current branch is still named `macOS` to preserve the existing repository history. The old bare repositories in `$HOME` were left in place during migration.

## What is managed

- Zsh and Powerlevel10k, including portable startup scripts under `zshrc/`
- tmux and Neovim source config, with tmux session, background-window, and notes helpers
- Pi agent settings and `APPEND_SYSTEM.md`
- macOS AeroSpace, Alacritty, Ghostty, Karabiner, MPD/rmpc, and Homebrew configuration
- Existing Arch Hyprland, Waybar, Tofi, Alacritty, and VSCodium configuration under `platforms/archlinux/`

Neovim's source configuration is included. Its machine-local `.git`, virtualenv, mamba install, and Jupyter runtime are not copied or linked. If a machine already has a separate Git repo at `~/.config/nvim`, the installer leaves it untouched; otherwise it links the Neovim config files. Pi auth, model-store, sessions, package installs, and SSH credentials are excluded. The Arch media-server helper uses normal interactive `sudo` and does not read a password file.

Some settings are hardware-specific, including the AeroSpace monitor assignment, MPD output device, and Hyprland monitor and wallpaper paths. Review them when moving to another machine, including `platforms/archlinux/.config/hypr/` on Linux. The previous `start-media-server` script depended on a local password file and was deliberately replaced with an interactive-sudo version.
