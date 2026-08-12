#!/bin/sh
# Regenerate the package manifests. Run before any migration, and
# occasionally so the git history shows what was added over time.
#
# xbps-query -m lists manually-installed packages only -- not the
# dependencies pulled in behind them, which is what makes it a usable
# install list rather than a system dump.
#
# Each manifest is written to a temp file and moved into place only on
# success. A failed query therefore leaves the previous record intact
# rather than truncating it to nothing, which is indistinguishable from
# a legitimate removal.
cd "$(dirname "$0")" || exit 1

if xbps-query -m | sed 's/-[^-]*$//' > .xbps-manual.tmp; then
	mv .xbps-manual.tmp xbps-manual.txt
else
	echo "dump.sh: xbps-query failed, xbps-manual.txt left unchanged" >&2
	rm -f .xbps-manual.tmp
fi

if flatpak list --app --columns=application > .flatpak-apps.tmp 2>/dev/null; then
	mv .flatpak-apps.tmp flatpak-apps.txt
else
	echo "dump.sh: flatpak list failed, flatpak-apps.txt left unchanged" >&2
	rm -f .flatpak-apps.tmp
fi

wc -l xbps-manual.txt flatpak-apps.txt
