#!/bin/sh
# Installs system configuration files for Framework 13 clamshell mode.
# Idempotent — safe to re-run after pulling updates from dotfiles.

set -eu

# ── Configuration ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ETC_SRC="$SCRIPT_DIR/etc"

# ── Self-elevate ──────────────────────────────────────────────────────────────

if [ "$(id -u)" -ne 0 ]; then
    echo "Re-running under sudo..."
    exec sudo "$0" "$@"
fi

# ── elogind configuration ─────────────────────────────────────────────────────

install -m 644 -o root -g root \
    "$ETC_SRC/elogind/logind.conf" \
    /etc/elogind/logind.conf
echo "installed: /etc/elogind/logind.conf"

# ── acpid event and handler ───────────────────────────────────────────────────

install -d -m 755 /etc/acpi/events

install -m 644 -o root -g root \
    "$ETC_SRC/acpi/events/lid" \
    /etc/acpi/events/lid
echo "installed: /etc/acpi/events/lid"

install -m 755 -o root -g root \
    "$ETC_SRC/acpi/lid.sh" \
    /etc/acpi/lid.sh
echo "installed: /etc/acpi/lid.sh"

# ── Enable acpid as a runit service ───────────────────────────────────────────

if [ ! -e /var/service/acpid ]; then
    ln -s /etc/sv/acpid /var/service/acpid
    echo "enabled: acpid runit service"
else
    echo "already enabled: acpid runit service"
fi

# ── Reload elogind ────────────────────────────────────────────────────────────

if pgrep -x elogind-daemon > /dev/null; then
    pkill -HUP -x elogind-daemon
    echo "reloaded: elogind-daemon (SIGHUP)"
else
    echo "warning: elogind-daemon not running; config will apply on next start"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Verify with:"
echo "  sudo sv status acpid"
echo "  grep -E '^HandleLidSwitch' /etc/elogind/logind.conf"
