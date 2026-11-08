#!/usr/bin/env bash
# Sets up Obsidian the same way on macOS (run from hypr-mac) and Linux (run from dotfiles): installs it, merges
# vault/*.json into the vault's .obsidian (these keys win, the rest is left alone), installs plugins.txt and turns
# them on. Safe to re-run; re-running also undoes another device switching vim mode off.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# the vault is synced by Syncthing (folder "obsidian"), .obsidian included
VAULT="${OBSIDIAN_VAULT:-$HOME/sync/obsidian/notes}"

if [ "$(uname)" = Darwin ]; then
	[ -d /Applications/Obsidian.app ] || brew install --cask obsidian
	command -v jq >/dev/null || brew install jq
	CFG="$HOME/Library/Application Support/obsidian"
else
	command -v obsidian >/dev/null || sudo pacman -S --needed obsidian
	command -v jq >/dev/null || sudo pacman -S --needed jq
	CFG="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian"
fi

if [ ! -d "$VAULT" ]; then
	echo "==> obsidian: no vault at $VAULT yet (Syncthing hasn't synced it?), skipping; re-run once it's there"
	exit 0
fi
O="$VAULT/.obsidian"
mkdir -p "$O/plugins"

# only write files that change: .obsidian syncs to every device, so rewriting them all would churn Syncthing
put() { # file new-content
	[ -f "$1" ] && [ "$(cat "$1")" = "$2" ] && return
	printf '%s\n' "$2" >"$1"
	echo "  updated ${1#"$VAULT"/}"
}

echo "==> obsidian: settings into $O"
for f in "$REPO"/vault/*.json; do
	t="$O/$(basename "$f")"
	put "$t" "$(jq -s '.[0] * .[1]' <([ -s "$t" ] && cat "$t" || echo '{}') "$f")"
done

echo "==> obsidian: plugins"
ids=()
while read -r id repo; do
	ids+=("$id")
	d="$O/plugins/$id"
	[ -f "$d/main.js" ] && continue
	mkdir -p "$d"
	for a in main.js manifest.json styles.css; do
		curl -fsSL -o "$d/$a" "https://github.com/$repo/releases/latest/download/$a" || rm -f "$d/$a"
	done
	echo "  installed $id"
done < <(grep -v -e '^#' -e '^$' "$REPO/plugins.txt")
t="$O/community-plugins.json"
put "$t" "$(jq -n --argjson have "$(cat "$t" 2>/dev/null || echo '[]')" '$have + ($ARGS.positional - $have)' --args "${ids[@]}")"

# open the vault on first launch instead of Obsidian's vault picker
if [ ! -f "$CFG/obsidian.json" ]; then
	mkdir -p "$CFG"
	jq -n --arg id "$(openssl rand -hex 8)" --arg p "$VAULT" --argjson ts "$(date +%s)000" \
		'{vaults: {($id): {path: $p, ts: $ts, open: true}}}' >"$CFG/obsidian.json"
	echo "  registered vault $VAULT"
fi
echo "==> obsidian: done (restart Obsidian if it was open)"
