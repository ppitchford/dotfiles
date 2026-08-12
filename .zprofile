# .zprofile
export XCURSOR_SIZE=64
export WLR_XCURSOR_SIZE=64
export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Session autostart. tty1 only — logging in on any other VT leaves this
# untouched, which is the recovery path for a bad session config.
if [[ -z $DISPLAY && -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
  export XDG_SESSION_TYPE=wayland
  export XDG_CURRENT_DESKTOP=mango
  exec dbus-run-session /usr/bin/mango -s ~/.local/bin/wayland-session
fi
