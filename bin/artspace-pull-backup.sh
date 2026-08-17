#!/usr/bin/env bash
set -euo pipefail

# Pull the latest artspace snapshot from the VPS.
#
# Scheduling note: this runs from cron on @reboot and hourly, both with
# --if-due, rather than at a fixed weekly time. A laptop is rarely powered on
# at any particular minute -- the previous "Sundays at 10:00" slot silently
# missed roughly thirteen weeks in a row -- and cronie never catches up a
# missed run. Firing often and letting the script decide is what makes the
# schedule survive an intermittently-on machine.
#
# No ssh-agent is needed: ~/.ssh/hetzner_hil is unencrypted and the host entry
# sets IdentitiesOnly, so ssh reads the key file directly. An earlier version
# sourced keychain's environment here, which had stopped resolving to a live
# agent socket and only ever looked load-bearing.

REMOTE="hetzner-hil:/home/philipp/backups/latest.db"
DEST_DIR="$HOME/backups/artspace"
STAMP="$DEST_DIR/.last-pull"
LOCKFILE="$DEST_DIR/.lock"

INTERVAL_DAYS=7    # pull at most this often
RETENTION_DAYS=56  # 8 weeks
KEEP_MINIMUM=4     # never prune below this many, however old they are

log() { printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }

mkdir -p "$DEST_DIR"

# --if-due: exit quietly unless the last successful pull is old enough. Cron
# calls it this way, so the common case produces no output and the log records
# attempts rather than ticks. Without this the hourly trigger would append 168
# lines a week saying nothing happened.
if [ "${1:-}" = "--if-due" ]; then
    if [ -e "$STAMP" ] && [ -z "$(find "$STAMP" -maxdepth 0 -mtime "+$((INTERVAL_DAYS - 1))")" ]; then
        exit 0
    fi
fi

# Hold a lock for the rest of the run. @reboot and the hourly tick can land
# together, and a slow transfer should not race a second copy of itself.
# Failing to take the lock is a normal outcome, not an error.
exec 9>"$LOCKFILE"
if ! flock -n 9; then
    exit 0
fi

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
DEST="$DEST_DIR/artspace-pulled-${TIMESTAMP}.db"

trap 'log "pull FAILED (exit $?): $REMOTE"' ERR

# -L dereferences the remote symlink and pulls the snapshot file itself.
# -p preserves perms, -t preserves the original mtime (i.e. when the VPS
# .backup actually ran) so you can correlate to the source snapshot if needed.
rsync -Lpt "$REMOTE" "$DEST"

# Only a completed transfer counts as a pull, so a failure above leaves the
# stamp alone and the next trigger retries instead of waiting out the week.
touch "$STAMP"

# Prune snapshots past the retention window, but never below KEEP_MINIMUM.
# Retention alone is not safe here: after a long gap every local copy is older
# than the window, and an unguarded prune would delete all of them the moment a
# fresh one arrived. Sorting is by mtime, which rsync -t set to the source
# snapshot's time rather than the pull's.
while IFS= read -r old; do
    [ -n "$old" ] || continue
    if [ -n "$(find "$old" -maxdepth 0 -mtime "+${RETENTION_DAYS}")" ]; then
        rm -f -- "$old"
        log "pruned: $(basename "$old")"
    fi
done < <(ls -1t "$DEST_DIR"/artspace-pulled-*.db 2>/dev/null | tail -n "+$((KEEP_MINIMUM + 1))")

log "pull ok: $DEST"
