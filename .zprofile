# .zprofile
export XCURSOR_SIZE=64
export WLR_XCURSOR_SIZE=64
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

if [[ -z $DISPLAY && -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
  comp=$(cat ~/.config/compositor 2>/dev/null || echo dwl)
  export XDG_SESSION_TYPE=wayland
  export XDG_CURRENT_DESKTOP=$comp
  exec dbus-run-session sh -c "~/.local/bin/dwl-status | $comp -s ~/.local/bin/dwl-session"
fi
