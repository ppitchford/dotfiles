#!/bin/sh
# Framework 13 clamshell handler
# - Lid closed + external monitor + AC : disable eDP-1, restart bar, stay awake
# - Lid closed otherwise               : suspend via zzz
# - Lid opened                         : re-enable eDP-1, restart bar

USER_NAME="philipp"
USER_ID=$(id -u "$USER_NAME" 2>/dev/null) || exit 0
RUNTIME_DIR="/run/user/$USER_ID"

# ── Lid state ────────────────────────────────────────────────────────────────

lid_state=""
for f in /proc/acpi/button/lid/*/state; do
    [ -f "$f" ] || continue
    lid_state=$(awk '{print $NF}' "$f")
    break
done
[ -z "$lid_state" ] && exit 0

# ── Wayland session detection ────────────────────────────────────────────────

wayland_display=""
if [ -d "$RUNTIME_DIR" ]; then
    wayland_display=$(find "$RUNTIME_DIR" -maxdepth 1 -name 'wayland-*' \
        ! -name '*.lock' -printf '%f\n' 2>/dev/null | head -1)
fi

as_user() {
    [ -n "$wayland_display" ] || return 0
    sudo -u "$USER_NAME" \
        XDG_RUNTIME_DIR="$RUNTIME_DIR" \
        WAYLAND_DISPLAY="$wayland_display" \
        "$@"
}

# Restart quickshell so the bar re-anchors to the current screen layout
restart_quickshell() {
    as_user pkill -x quickshell 2>/dev/null
    sleep 0.4
    as_user setsid -f quickshell >/dev/null 2>&1
}

# ── External monitor + AC detection ──────────────────────────────────────────

external_connected=0
for s in /sys/class/drm/card*/status; do
    [ -f "$s" ] || continue
    case "$s" in *eDP*) continue ;; esac
    [ "$(cat "$s")" = "connected" ] && external_connected=1 && break
done

ac_online=0
for ps in /sys/class/power_supply/*; do
    [ -f "$ps/type" ] || continue
    [ "$(cat "$ps/type")" = "Mains" ] || continue
    [ "$(cat "$ps/online" 2>/dev/null)" = "1" ] && ac_online=1 && break
done

# ── Action ───────────────────────────────────────────────────────────────────

case "$lid_state" in
    closed)
        if [ "$external_connected" = "1" ] && [ "$ac_online" = "1" ]; then
            as_user /usr/bin/wlr-randr --output eDP-1 --off
            sleep 0.3
            restart_quickshell
        else
            /usr/sbin/zzz
        fi
        ;;
    open)
        as_user /usr/bin/wlr-randr --output eDP-1 --on
        sleep 0.3
        restart_quickshell
        ;;
esac
