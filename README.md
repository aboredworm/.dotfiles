# Dotfiles

A regular Git repository for shared shell, terminal, editor, Pi, and desktop configuration. The installer links selected files into `$HOME`; it does not track the whole home directory.

## Install

On a fresh Arch install, install Git (`sudo pacman -S --needed git`), then:

```sh
mkdir -p ~/projects
git clone --branch archlinux git@github.com:aboredworm/.dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./install.sh --packages
```

On macOS, install Apple's Command Line Tools (`xcode-select --install`) and Homebrew first, then clone the `macOS` branch and run the same installer. Both branches support the same profiles.

Use `./install.sh` without `--packages` to link configuration only.

The installer chooses the macOS profile on macOS, the Arch Linux profile on Arch, and the common CLI profile elsewhere. Select a profile explicitly with `--profile macos`, `--profile archlinux`, or `--profile common`.

Existing files and directories that would be replaced are moved to a dated directory under `~/.dotfiles-backup/`. Re-running the installer is safe. Preview its actions with `./install.sh --dry-run`.

Package installation is opt-in:

```sh
./install.sh --packages
```

On macOS this runs Homebrew Bundle from `Brewfile` with `--no-upgrade`, then installs MiniLaunch and its font. Missing packages are installed, but already-installed packages are not broadly upgraded. The installer adds AeroSpace's tap and, on Homebrew versions with tap-trust controls, trusts only its named cask. Brewfile entries are not exact-version locks; Homebrew resolves current releases (versioned formula names such as `python@3.14` only constrain the major/minor line). Run `brew bundle upgrade --file=~/projects/dotfiles/Brewfile` when you want to update them. On Arch it runs `sudo pacman -S --needed` with `platforms/archlinux/packages.txt`, prompting normally through `sudo`. It does not refresh package databases or perform a system upgrade; update Arch separately with `sudo pacman -Syu` before installing against stale databases. AUR tools such as hyprshade, micromamba, Quarto, and dooit are optional and are not installed automatically. Other Linux distributions get the common dotfiles only; install their dependencies separately.

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

The GitHub repository is `git@github.com:aboredworm/.dotfiles.git`. This branch is `archlinux`; macOS changes live on `macOS`. The `dfc` shell function runs Git in the checkout resolved through the installed `~/zshrc` symlink, or in `$DOTFILES_DIR` when explicitly set.

### Moving from the old bare repository

Do not clone into `~/dotfiles` if it is already a bare Git repository. Use `~/projects/dotfiles` (or another empty path). Keep the bare repository and any local edits until you have reviewed the installer preview:

```sh
cd ~/projects/dotfiles
./install.sh --profile archlinux --dry-run
# After reviewing the proposed backups and links:
./install.sh --profile archlinux
```

Installing replaces the managed live configs with links, backing up the old files first; it does not import uncommitted home-directory edits. In particular, review any local Hyprland Lua/config migration before installing: the checked-in Arch profile still uses `hyprland.conf`. Port local edits into the checkout first if they should remain active. Do not use the old bare-repo `dfc` alias to maintain the new layout.

## What is managed

- Zsh and Powerlevel10k, including portable startup scripts under `zshrc/`
- tmux and Neovim source config, with tmux session, background-window, and notes helpers
- Pi agent settings and `APPEND_SYSTEM.md`
- macOS AeroSpace, MiniLaunch, Alacritty, Ghostty, Karabiner, MPD/rmpc, and Homebrew configuration
- Arch Hyprland, Hyprpaper, hyprshade/nightlight, Waybar, Tofi, Alacritty, and VSCodium configuration under `platforms/archlinux/`

The common and Arch profiles do not link macOS desktop configs or run Homebrew/MiniLaunch. Shared shell setup detects optional commands and uses Linux paths for pnpm and NAS mounts. Arch keeps `~/.histfile` as its default history file; an existing `$HISTFILE` is respected. PDF preview helpers resolve Quarto and Zathura from `PATH`. Neovim's plugins, language servers, and optional notebook/LaTeX tools still need their own setup.

Neovim's source configuration is included. Its machine-local `.git`, virtualenv, mamba install, and Jupyter runtime are not copied or linked. If a machine already has a separate Git repo at `~/.config/nvim`, the installer leaves it untouched; otherwise it links the Neovim config files. Pi auth, model-store, sessions, package installs, and SSH credentials are excluded. The Arch media-server helper uses normal interactive `sudo` and does not read a password file.

Some settings remain machine-specific. The AeroSpace display toggle reads its UUID from `~/.config/aerospace/display-uuid`, which is excluded from Git. The `mount-nas` helper expects `NAS_HOST` and `NAS_EXPORT` to be set locally; `NAS_MOUNT_POINT` overrides `/mnt/nas` on Linux or `/Volumes/nas` on macOS. Review the Hyprland monitor and wallpaper paths under `platforms/archlinux/.config/hypr/` when moving to Linux. The AeroSpace `Option+Shift+M` monitor toggle requires the free [`aspace` CLI](https://github.com/asumaran/aspace) at `~/.local/bin/aspace`. The Arch media-server helper accepts a device path as its argument and uses interactive `sudo`.
