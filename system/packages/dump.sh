#!/bin/sh
# Regenerate the package manifests. Run before any migration, and
# occasionally so the git history shows what was added over time.
#
# xbps-query -m lists manually-installed packages only — not the
# dependencies pulled in behind them, which is what makes it a usable
# install list rather than a system dump.

cd "$(dirname "$0")" || exit 1

xbps-query -m | sed 's/-[^-]*$//' > xbps-manual.txt
flatpak list --app --columns=application 2>/dev/null > flatpak-apps.txt

wc -l xbps-manual.txt flatpak-apps.txt
