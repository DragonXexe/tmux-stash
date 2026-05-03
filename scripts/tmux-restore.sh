#!/usr/bin/env bash

pop_command="$(dirname $0)/pop.sh"

if [[ $# -ne 1 ]]; then
    echo "Usage:"
    echo "tmux-restore.sh <sesion-name>"
    echo ""
    exit 1
fi
set -e

$pop_command $1

tmux a -t $1
