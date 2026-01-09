# ~/.bashrc
clear && myfetch -c 8 -C " █"
eval "$(starship init bash)"
[[ $- != *i* ]] && return
alias lsd='eza --icons'
alias pacup='sudo pacman -Rns $(pacman -Qdtq)'
alias grep='grep --color=auto'
alias pool='clear && asciiquarium'
alias f='clear && myfetch -i e -f -c 16 -C "  "'
alias bye='sudo shutdown -h now'
alias loop='sudo reboot'
alias h='dbus-launch Hyprland'
alias fonts='fc-list -f "%{family}\n"'
alias spot="ncspot"
alias untar="tar -xf"
alias n="nvim"
alias ls='exa --icons'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
PS1='[\u@\h \W]\$ '
PATH=/opt/toolchains/riscv/bin/:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl


# === SSH Agent Setup ===
# Start ssh-agent if not already running, and add default key
if ! pgrep -u "$USER" ssh-agent > /dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null
fi

# Add key if no identities are loaded
if ! ssh-add -l >/dev/null 2>&1; then
    ssh-add ~/.ssh/fa2025_school >/dev/null 2>&1
fi

export PATH=$PATH:/home/michael/.spicetify
