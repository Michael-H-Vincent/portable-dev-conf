# Dotfiles (Arch + Hyprland)

This repository contains my personal Linux dotfiles and setup scripts, primarily targeting Arch Linux with Hyprland. The goal is to clone this repo on a new machine and quickly reproduce my development environment and desktop setup.

## What's Included

- Hyprland configuration
- Hyprpaper and a systemd user timer for cycling wallpapers
- Terminal setup (Kitty + Starship)
- Neovim configuration (LazyVim)
- Tmux configuration (with TPM)
- Wofi configuration
- Thunar configuration
- Bash configuration
- systemd user units
- An install script to bootstrap everything

## Repository Layout

```
.
├── README.md
├── install.sh
└── config
    ├── .bashrc
    ├── .tmux.conf
    ├── hypr/
    ├── hyprpanel/
    ├── hyprpaper/
    ├── kitty/
    ├── nvim/
    ├── starship/
    ├── wofi/
    └── systemd/
        └── user/
            ├── timed_wallpaper.service
            └── timed_wallpaper.timer
```

All contents of `config/` are symlinked into the appropriate locations (`~/.config` or `~/`) by the installer.

## Requirements

- Arch Linux (primary target)
- `git`
- `bash`
- Internet connection

Other distributions may work for symlinking, but package installation is currently Arch-focused.

## Installation

Clone the repository:

```bash
git clone <your-repo-url>
cd dotfiles
```

### Full Install (New Machine)

Installs required packages, bootstraps `yay` if needed, sets up services, and creates all symlinks:

```bash
./install.sh
```

This will:

- Install development tools and desktop software
- Install and enable PipeWire and Bluetooth
- Install TPM (tmux plugin manager)
- Symlink all configs
- Enable the wallpaper cycling systemd user timer

### Links Only (Existing System)

If you already have the software installed and only want to apply the configs:

```bash
./install.sh --links-only
```

This mode:

- Backs up only the files and directories that will be overwritten
- Creates symlinks for all configs
- Does not install packages or enable services

Backups are stored under:

```
~/.dotfiles_backup_<timestamp>/
```

## Neovim and Tmux Plugins

- Neovim uses LazyVim. Open `nvim` once after installation to sync plugins.
- Tmux uses TPM. Inside tmux, press `<prefix>` + `I` to install plugins.

## Fonts

This setup uses Nerd Fonts. The terminal is configured for a Nerd Font, specifically Hermit Nerd Font or an equivalent.

## Notes

- The installer is idempotent and can be safely re-run.
- Symlinks ensure all configuration changes live in this repository and can be tracked with Git.
- systemd user services are placed under `~/.config/systemd/user`.

## License

Personal configuration. Use, adapt, or copy at your own risk.
