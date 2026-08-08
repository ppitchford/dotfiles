# .zprofile
export XCURSOR_SIZE=64
export WLR_XCURSOR_SIZE=64
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

if [[ -z $DISPLAY && -z $WAYLAND_DISPLAY ]]; then
  export XDG_SESSION_TYPE=wayland
  export XDG_CURRENT_DESKTOP=mango
  exec dbus-run-session mango
fi
