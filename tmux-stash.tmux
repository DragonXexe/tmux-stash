#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tmux bind-key C-s run-shell "${CURRENT_DIR}/scripts/store.sh"
tmux bind-key C-r command-prompt -p "Restore session:" "run-shell '${CURRENT_DIR}/scripts/pop.sh %1'"
