
# ~/.bashrc

clear && myfetch -c 8 -C " █"

# Only run interactive stuff in interactive shells
[[ $- != *i* ]] && return

# --- Starship (full by default, toggle to simple) ---
export STARSHIP_FULL_CONFIG="$HOME/.config/starship/starship.toml"
export STARSHIP_SIMPLE_CONFIG="$HOME/.config/starship/starship-simple.toml"

# Default to full prompt unless STARSHIP_CONFIG is already set externally
: "${STARSHIP_CONFIG:=$STARSHIP_FULL_CONFIG}"
export STARSHIP_CONFIG

eval "$(starship init bash)"

# Toggle prompt between full and simple (bash version)
p() {
  if [[ "${STARSHIP_CONFIG:-}" == "$STARSHIP_SIMPLE_CONFIG" ]]; then
    export STARSHIP_CONFIG="$STARSHIP_FULL_CONFIG"
  else
    export STARSHIP_CONFIG="$STARSHIP_SIMPLE_CONFIG"
  fi
  echo
}

# --- Aliases ---
alias pacup='sudo pacman -Rns $(pacman -Qdtq)'
alias grep='grep --color=auto'
alias f='clear && myfetch -i e -f -c 16 -C "  "'
alias h='dbus-launch Hyprland'
alias n='nvim'
alias ls='exa --icons'

# --- NVM ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# NOTE: Starship sets PS1; keeping this would override it.
# PS1='[\u@\h \W]\$ '

# --- PATH ---
export PATH="/opt/toolchains/riscv/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$PATH"
export PATH="$PATH:$HOME/.spicetify"

# --- SSH Agent Setup ---
if ! pgrep -u "$USER" ssh-agent > /dev/null 2>&1; then
  eval "$(ssh-agent -s)" >/dev/null
fi

if ! ssh-add -l >/dev/null 2>&1; then
  ssh-add "$HOME/.ssh/fa2025_school" >/dev/null 2>&1
fi
