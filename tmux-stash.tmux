#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmux bind-key T run-shell "$CURRENT_DIR/scripts/store.sh"
tmux bind-key P run-shell "$CURRENT_DIR/scripts/pop.sh"
bind C-r command-prompt -p "Save session:" "run-shell '~/.tmux/plugins/tmux-stash/scripts/pop.sh %1'"
bind C-s run-shell "~/.tmux/plugins/tmux-stash/scripts/store.sh"
