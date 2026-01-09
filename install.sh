#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Dotfiles installer (Arch-first)
#
# Repo layout (yours):
#   repo/
#     README.md
#     install.sh
#     config/
#       .bashrc
#       .tmux.conf
#       hypr/ nvim/ kitty/ ...
#       systemd/user/timed_wallpaper.{service,timer}
#
# What this does:
# - By default: installs packages + yay + tpm, links configs, enables services, enables timer
# - With --links-only: ONLY backs up the specific targets that would be overwritten
#   and creates symlinks (no installs, no service enabling)
# ------------------------------------------------------------

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_ROOT/config"

BASHRC_SRC="$CONFIG_SRC/.bashrc"
TMUX_CONF_SRC="$CONFIG_SRC/.tmux.conf"
SYSTEMD_USER_SRC="$CONFIG_SRC/systemd/user"

LINKS_ONLY=0
if [[ "${1:-}" == "--links-only" ]]; then
  LINKS_ONLY=1
  shift
fi

log()  { printf "\033[1;32m[+]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }
die()  { printf "\033[1;31m[x]\033[0m %s\n" "$*"; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

timestamp() { date +%Y%m%d_%H%M%S; }

# Backup JUST the targets we are about to overwrite, into one folder:
#   ~/.dotfiles_backup_<ts>/{.bashrc,.tmux.conf,.config/<name>,...}
backup_targets=()

queue_backup_target() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    backup_targets+=("$target")
  fi
}

backup_queued_targets() {
  local ts dst rel
  ts="$(timestamp)"
  dst="$HOME/.dotfiles_backup_${ts}"

  if [[ "${#backup_targets[@]}" -eq 0 ]]; then
    log "No existing targets to back up (nothing will be overwritten)."
    return
  fi

  log "Backing up ${#backup_targets[@]} target(s) -> $dst"
  mkdir -p "$dst"

  for t in "${backup_targets[@]}"; do
    # Make a relative path (strip $HOME/) so we can preserve layout under backup dir
    rel="${t#"$HOME"/}"
    mkdir -p "$dst/$(dirname -- "$rel")"
    cp -a "$t" "$dst/$rel"
    log "Backed up: $t -> $dst/$rel"
  done
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local bak="${target}.bak.$(timestamp)"
    log "Backing up: $target -> $bak"
    mv -f "$target" "$bak"
  fi
}

link_path() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname -- "$dst")"
  backup_if_exists "$dst"
  ln -sfn "$src" "$dst"
  log "Linked: $dst -> $src"
}

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

ensure_yay() {
  have yay && { log "yay already installed"; return; }
  have pacman || die "pacman not found; cannot install yay."

  log "Installing prerequisites for yay..."
  sudo pacman -S --needed --noconfirm git base-devel

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  log "Cloning yay into $tmpdir..."
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  log "Building yay (makepkg)..."
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)

  have yay || die "yay install failed."
  log "yay installed successfully"
}

install_arch_packages() {
  have pacman || die "pacman not found. Arch install path requires pacman."

  log "Syncing package database..."
  sudo pacman -Sy --noconfirm

  local pkgs=(
    base-devel git curl wget unzip zip tar ripgrep fd fzf
    hyprland hyprpaper thunar tmux kitty neovim starship wofi
    bluez bluez-utils blueman
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber pavucontrol
    ttf-nerd-fonts-symbols
  )

  log "Installing pacman packages..."
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"

  ensure_yay
  local aur_pkgs=(
    hyprpanel
    spotify
    discord
    # TODO: add your exact Hermit Nerd Font package name once confirmed:
    # ttf-hermit-nerd
  )

  log "Installing AUR packages with yay..."
  yay -S --needed --noconfirm "${aur_pkgs[@]}" || warn "Some AUR packages failed."
}

install_packages() {
  local distro
  distro="$(detect_distro)"
  case "$distro" in
    arch|endeavouros|manjaro) install_arch_packages ;;
    *) warn "Distro '$distro' not supported for package install yet. Skipping installs." ;;
  esac
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ -d "$tpm_dir/.git" ]]; then
    log "TPM already present: $tpm_dir"
  else
    log "Installing TPM..."
    mkdir -p "$(dirname -- "$tpm_dir")"
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
}

enable_bluetooth() {
  if have systemctl; then
    log "Enabling bluetooth service..."
    sudo systemctl enable --now bluetooth.service || warn "Failed to enable bluetooth.service"
  else
    warn "systemctl not found; cannot enable bluetooth service"
  fi
}

enable_pipewire_user() {
  if have systemctl; then
    log "Enabling PipeWire user services..."
    systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service \
      || warn "Failed to enable one or more PipeWire user services"
  else
    warn "systemctl not found; cannot enable PipeWire user services"
  fi
}

queue_backups_for_links() {
  [[ -d "$CONFIG_SRC" ]] || die "Missing config directory: $CONFIG_SRC"

  # Home dotfiles
  queue_backup_target "$HOME/.bashrc"
  queue_backup_target "$HOME/.tmux.conf"

  # ~/.config targets that will be linked from repo config/*
  shopt -s dotglob nullglob
  for item in "$CONFIG_SRC"/*; do
    local base dst
    base="$(basename -- "$item")"
    case "$base" in
      .bashrc|.tmux.conf) continue ;;
    esac
    dst="$HOME/.config/$base"
    queue_backup_target "$dst"
  done
  shopt -u dotglob nullglob
}

link_repo_configs() {
  [[ -d "$CONFIG_SRC" ]] || die "Missing config directory: $CONFIG_SRC"

  mkdir -p "$HOME/.config"

  [[ -e "$BASHRC_SRC" ]] && link_path "$BASHRC_SRC" "$HOME/.bashrc" || warn "Missing: $BASHRC_SRC"
  [[ -e "$TMUX_CONF_SRC" ]] && link_path "$TMUX_CONF_SRC" "$HOME/.tmux.conf" || warn "Missing: $TMUX_CONF_SRC"

  shopt -s dotglob nullglob
  for item in "$CONFIG_SRC"/*; do
    local base
    base="$(basename -- "$item")"
    case "$base" in
      .bashrc|.tmux.conf) continue ;;
    esac
    link_path "$item" "$HOME/.config/$base"
  done
  shopt -u dotglob nullglob
}

setup_systemd_user_units() {
  have systemctl || { warn "systemctl not found; skipping systemd user units."; return; }

  if [[ -e "$SYSTEMD_USER_SRC/timed_wallpaper.timer" ]]; then
    log "Reloading systemd --user daemon..."
    systemctl --user daemon-reload || true

    log "Enabling timed_wallpaper.timer..."
    systemctl --user enable --now timed_wallpaper.timer

    log "Timers (filtered):"
    systemctl --user list-timers --all | grep -E 'timed_wallpaper|NEXT|UNIT' || true
  else
    warn "No timed_wallpaper.timer found at: $SYSTEMD_USER_SRC/timed_wallpaper.timer"
  fi
}

main() {
  log "Repo root: $REPO_ROOT"
  log "Config source: $CONFIG_SRC"

  if [[ "$LINKS_ONLY" -eq 1 ]]; then
    log "Mode: --links-only (backup only overwritten targets + create symlinks)"
    queue_backups_for_links
    backup_queued_targets
    link_repo_configs
    log "Done (--links-only)."
    exit 0
  fi

  # Full install mode
  queue_backups_for_links
  backup_queued_targets

  install_packages
  install_tpm

  log "Linking configs..."
  link_repo_configs

  log "Enabling services..."
  enable_bluetooth
  enable_pipewire_user

  log "Setting up systemd user timer/service..."
  setup_systemd_user_units

  log "Done."
  warn "Next steps:"
  warn "- Open tmux and press prefix + I to install TPM plugins."
  warn "- Open nvim once to let LazyVim/lazy.nvim sync plugins."
}

main "$@"
