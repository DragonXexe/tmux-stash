#!/usr/bin/env bash

# `pop.sh <sesion1> [<sessionN> ...]`
# `pop.sh` accepts at least one argument and restores the sessions specified, if they exist.
# It does this by reading the last file it finds that was stored by store.sh
#

source "$(dirname $0)/variables.sh"

# This is used by create_complete_window and set by pop_session
SESSION_LINES=""

# This will pop a session passed in $1
pop_session() {
    # Get the last stash
    local last_path=$(readlink "$STASH_PATH/$1_last")
    # Recover
    local items
    mapfile <$last_path -t items

    tmux new-session -d -s $1
    echo "Created session: $1"

    SESSION_LINES=("${items[@]}")

    for line in "${items[@]}"; do
        if [[ $line == "window"* ]]; then
            create_complete_window $line
        fi
    done
}
create_complete_window() {
    local session_name=$2
    local window_index=$3
    local window_name=${4#:} # this syntax strips the prefixed colon
    local window_active=$5
    local window_flags=${6#:}
    local window_layout=$7
    # First create a new tmux window
    create_new_window $@
    for line in "${SESSION_LINES[@]}"; do
        local expected_prefix="pane${delimiter}${session_name}${delimiter}${window_index}"
        if [[ $line == "${expected_prefix}"* ]]; then
            create_pane $line
        fi
    done
    apply_window_layout $@
}
# The arguments are the lines starting with window from a stash
create_new_window() {
    local session_name=$2
    local window_index=$3
    local window_name=${4#:} # this syntax strips the prefixed colon
    local window_active=$5
    local window_flags=${6#:}
    local window_layout=$7
    echo "Creating window $session_name:$window_name"
    tmux new-window -t "$session_name:$window_index" -n $window_name
}

create_pane() {
    local session_name=$2
    local window_index=$3
    local window_active=$4
    local window_flags=${5#:}
    local pane_index=$6
    local pane_current_path=${7#:}
    echo "pane_current_path=$pane_current_path"
    local pane_active=$8
    local pane_current_command=$9
    local pane_pid=${10}
    local history_size=${11}
    echo "Creating pane $session_name:$pane_index"
    if [[ "$pane_index" != 0 ]]; then
        tmux select-layout -t "${session_name}:${window_index}" tiled
        tmux split-window -t $session_name:$window_index -l $history_size -c $pane_current_path
    else
            tmux respawn-pane -k -t "$session_name:$window_index.$pane_index" -c "$pane_current_path"
    fi
}
apply_window_layout() {
    local session_name=$2
    local window_index=$3
    local window_name=${4#:} # this syntax strips the prefixed colon
    local window_active=$5
    local window_flags=${6#:}
    local window_layout=$7
    tmux select-layout -t "${session_name}:${window_index}" "$window_layout"
}

if [[ $# -lt 1 ]]; then
    echo "Usage:"
    echo "pop.sh <sesion1> [<sessionN> ...]"
    echo ""
    exit 1
fi
# get the sessions
pop_session $1
