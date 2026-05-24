#!/usr/bin/env bash

source "$(dirname $0)/variables.sh"

pop_command="$(dirname $0)/pop.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage:"
    echo "\ttmux-restore.sh <sesion-name>"
    echo "\ttmux-restore.sh --list"
    echo ""
    exit 1
fi
if [[ "$1" == "--list" ]]; then
    find "$STASH_PATH" -maxdepth 1 -type f -printf '%f\n' |
        while read -r name; do
            # Strip trailing _YYYYMMDDTHHMMSS if present
            base=$(printf '%s\n' "$name" |
                sed -E 's/_[0-9]{8}T[0-9]{6}$//')

            # Only print if it actually matched the pattern
            [[ "$base" != "$name" ]] && printf '%s\n' "$base"
        done | sort -u
    exit 0
fi
set -e

$pop_command $1

tmux a -t $1
