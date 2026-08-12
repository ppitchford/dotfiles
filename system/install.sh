#!/bin/sh
# Installs the root-owned files this machine needs: Framework 13 clamshell mode,
# and timezone auto-detection on network connect.
# Idempotent — safe to re-run after pulling updates from dotfiles.

set -eu

# ── Configuration ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ETC_SRC="$SCRIPT_DIR/etc"
BIN_SRC="$SCRIPT_DIR/usr/local/bin"

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

# ── greetd and tuigreet ───────────────────────────────────────────────────────
install -d -m 755 /etc/greetd
install -m 644 -o root -g root \
    "$ETC_SRC/greetd/config.toml" \
    /etc/greetd/config.toml
echo "installed: /etc/greetd/config.toml"

install -m 755 -o root -g root \
    "$ETC_SRC/greetd/tuigreet-start" \
    /etc/greetd/tuigreet-start
echo "installed: /etc/greetd/tuigreet-start"

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

# ── Timezone auto-detection ───────────────────────────────────────────────────
# Geolocates the public IP on each DHCP lease and repoints /etc/localtime.
# dhcpcd already runs as root, so this needs no sudoers rule.

install -m 755 -o root -g root \
    "$BIN_SRC/tz-from-ip" \
    /usr/local/bin/tz-from-ip
echo "installed: /usr/local/bin/tz-from-ip"

install -m 644 -o root -g root \
    "$ETC_SRC/dhcpcd.exit-hook" \
    /etc/dhcpcd.exit-hook
echo "installed: /etc/dhcpcd.exit-hook"

# Set the zone now instead of waiting for the next lease. Never fatal: a fresh
# install may have no network yet, and `set -e` would otherwise abort the run.
if /usr/local/bin/tz-from-ip; then
    echo "timezone: $(readlink /etc/localtime)"
else
    echo "warning: timezone lookup failed; will retry on the next DHCP lease"
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
echo "  readlink /etc/localtime          # follows your location on connect"
echo "  cat /var/log/tz-from-ip.log      # why it did or didn't change"
