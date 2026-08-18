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

# npm globals hold the language servers Neovim resolves off PATH -- tsgo via
# typescript, plus html, cssls and jsonls via vscode-langservers-extracted.
# Without this manifest a rebuild leaves the editor with no servers at all.
#
# npm's status is checked before the transform rather than after: in a pipeline
# the shell reports only the last command's status, so `npm ls | sed` would look
# successful even when npm failed.
if npm ls -g --depth=0 --parseable > .npm-global.raw 2>/dev/null; then
	tail -n +2 .npm-global.raw | sed 's|.*/node_modules/||' > .npm-global.tmp
	mv .npm-global.tmp npm-global.txt
else
	echo "dump.sh: npm ls failed, npm-global.txt left unchanged" >&2
	rm -f .npm-global.tmp
fi
rm -f .npm-global.raw

wc -l xbps-manual.txt flatpak-apps.txt npm-global.txt
