if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec start-hyprland
fi

if [[ -z "$GNOME_KEYRING_CONTROL" ]]; then
    [[ -z "$GNOME_KEYRING_CONTROL" ]] && eval $(gnome-keyring-daemon --start 2>/dev/null)
fi
export SSH_AUTH_SOCK

export EDITOR='nvim'