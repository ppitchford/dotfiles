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

# ── Login ─────────────────────────────────────────────────────────────────────
# Nothing to install. Login is agetty on tty1, which Void enables by default;
# `.zprofile` execs the compositor from the tty1 login shell. greetd and tuigreet
# were removed 2026-08-14 — see the Desktop made for one note for the reasoning.

# ── Root-owned /run/dbus ──────────────────────────────────────────────────────
# Runs before any service, so it wins the race against /etc/sv/dbus/run, which
# would otherwise create the directory as dbus:dbus. 1Password rejects polkit
# for system authentication unless the bus socket's path is root-owned.

install -m 755 -o root -g root \
    "$ETC_SRC/runit/core-services/06-dbus-root-dir.sh" \
    /etc/runit/core-services/06-dbus-root-dir.sh
echo "installed: /etc/runit/core-services/06-dbus-root-dir.sh"

# ── polkit fingerprint authentication ─────────────────────────────────────────
# Lets polkit actions accept the Goodix reader before falling back to a password.
# 1Password unlocks through polkit, so this is what wires the reader to the app.

install -d -m 755 /etc/pam.d

install -m 644 -o root -g root \
    "$ETC_SRC/pam.d/polkit-1" \
    /etc/pam.d/polkit-1
echo "installed: /etc/pam.d/polkit-1"

# Same reader for sudo. Unlike polkit-1 this overwrites a package-owned file —
# see the header of system/etc/pam.d/sudo before changing it.

install -m 644 -o root -g root \
    "$ETC_SRC/pam.d/sudo" \
    /etc/pam.d/sudo
echo "installed: /etc/pam.d/sudo"

# Enrolment, which is a separate permission from the verification the PAM
# stacks above perform. Missing this, `fprintd-enroll` fails and nothing else
# does — so the gap only surfaces when a finger has to be re-registered.

# mkdir, not `install -d`: polkit ships rules.d with its own restrictive mode
# and ownership, and install would reset both every run.
mkdir -p /etc/polkit-1/rules.d

install -m 644 -o root -g root \
    "$ETC_SRC/polkit-1/rules.d/50-fprintd.rules" \
    /etc/polkit-1/rules.d/50-fprintd.rules
echo "installed: /etc/polkit-1/rules.d/50-fprintd.rules"

# ── 1Password browser allowlist ───────────────────────────────────────────────
# Helium is not a browser 1Password recognises, so without this the extension
# cannot reach the desktop app, and the unlock never reaches polkit or the
# reader. 1Password reads it on start; restart the app after a change.

install -d -m 755 /etc/1password

install -m 644 -o root -g root \
    "$ETC_SRC/1password/custom_allowed_browsers" \
    /etc/1password/custom_allowed_browsers
echo "installed: /etc/1password/custom_allowed_browsers"

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

# ── iwd ───────────────────────────────────────────────────────────────────────
# The iwd package ships no main.conf at all, so this file is entirely ours:
# without it iwd falls back to its own defaults and DNS stops going through
# resolvconf. Mirrored as-is; dhcpcd holds the wireless lease in practice, and
# that is what makes dhcpcd.exit-hook below fire.

install -d -m 755 -o root -g root /etc/iwd
install -m 644 -o root -g root \
    "$ETC_SRC/iwd/main.conf" \
    /etc/iwd/main.conf
echo "installed: /etc/iwd/main.conf"

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

# The process is /usr/libexec/elogind/elogind, whose name is `elogind`. It was
# matched as `elogind-daemon` here, which matches nothing — so this always took
# the else branch and never actually reloaded.
if pgrep -x elogind > /dev/null; then
    pkill -HUP -x elogind
    echo "reloaded: elogind (SIGHUP)"
else
    echo "warning: elogind not running; config will apply on next start"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Verify with:"
echo "  sudo sv status acpid"
echo "  cat /etc/1password/custom_allowed_browsers   # must list helium"
echo "  pkexec true                      # should ask for the reader first"
echo "  stat -c '%U:%G' /run/dbus        # must be root:root after a reboot"
echo "  sudo -k && sudo true             # should ask for the reader first"
echo "  grep -E '^HandleLidSwitch' /etc/elogind/logind.conf"
echo "  readlink /etc/localtime          # follows your location on connect"
echo "  cat /var/log/tz-from-ip.log      # why it did or didn't change"
