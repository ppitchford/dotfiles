# vim: set ts=4 sw=4 et:

# Create /run/dbus owned by root before the dbus service gets the chance.
#
# Void's /etc/sv/dbus/run creates the directory as dbus:dbus, but only if it
# does not already exist — so winning the race here is enough, and no
# package-owned file needs editing. /etc/sv/dbus/run is not a conf_file, so an
# edit there would be silently reverted by the next dbus update.
#
# 1Password refuses to use polkit for system authentication unless every
# component of the path to the system bus socket is root-owned. It logs
# "insecure system D-Bus detected (BinaryPermissions)" and falls back to the
# master password. dbus-daemon starts as root and creates the socket before
# dropping to the dbus user, so it never needs to own the directory itself.

msg "Creating /run/dbus owned by root..."
install -m0755 -o root -g root -d /run/dbus
