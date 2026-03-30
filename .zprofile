# .zprofile
export XCURSOR_SIZE=64
export WLR_XCURSOR_SIZE=64

if [[ -z $DISPLAY && -z $WAYLAND_DISPLAY ]]; then
  export XDG_SESSION_TYPE=wayland
  export XDG_CURRENT_DESKTOP=mango
  exec dbus-run-session mango
fi
