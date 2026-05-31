#!/usr/bin/env bash

# `store.sh` safes all the running sessions
# It will store them in a file like this: `<session-name>_<time>`
#

source "$(dirname $0)/variables.sh"

# This will store a session passed in $1
store_session() {
	echo "Creating session for $1"
	# Create a filepath for each session
	mkdir -p $STASH_PATH

	local timestamp="$(date +"%Y%m%dT%H%M%S")"
	local new_stash_filename="${1}_${timestamp}"
	local new_stash_file="${STASH_PATH}/${new_stash_filename}"

	touch $new_stash_file

	# Generate the formatted output for the session
	# and store the output
	format_session_info $1 >$new_stash_file

	# Update the session specific last pointer
	ln -sf $new_stash_file $STASH_PATH/$1_last

}
# Takes the session in $1 and returns a string
format_session_info() {
	local panes
    mapfile -t panes < <(tmux list-panes -a -f "#{==:#{session_name},$1}" -F "$(pane_format)")

	local windows=$(tmux list-windows -a -f "#{==:#{session_name},$1}" -F "$(window_format)")
    local resulting_panes=()
    for item in ${panes[@]}; do
        local split_item
        IFS="$delimiter" read -ra split_item <<< "$item"
        resulting_panes+=("$item$(get_full_pane_command ${split_item[@]})")
    done

	echo "$windows"
	IFS=$'\n'
    panes="${resulting_panes[*]}"
    unset IFS
    echo "$panes"
}
# Takes a the pane_format of a pane and returns the full command
get_full_pane_command() {
    local pane_pid=${10}
    local pane_current_command=${9}
    local child
    child=$(pgrep -P "$pane_pid" -o)
    if [[ -z "$child" ]]; then
        echo ""
        return
    fi
    ps -o args= -p "$child"
}
pane_format() {
	local format
	format+="pane" #1
	format+="${delimiter}"
	format+="#{session_name}" #2
	format+="${delimiter}"
	format+="#{window_index}" #3
	format+="${delimiter}"
	format+="#{window_active}" #4
	format+="${delimiter}"
	format+=":#{window_flags}" #5
	format+="${delimiter}"
	format+="#{pane_index}" #6
	format+="${delimiter}"
	format+=":#{pane_current_path}" #7
	format+="${delimiter}"
	format+="#{pane_active}" #8
	format+="${delimiter}"
	format+="#{pane_current_command}" #9
	format+="${delimiter}"
	format+="#{pane_pid}" #10
	format+="${delimiter}"
	format+="#{history_size}" #11
	format+="${delimiter}"
    # pane_full_command gets added later as #12
	echo "$format"
}
window_format() {
	local format
	format+="window"
	format+="${delimiter}"
	format+="#{session_name}"
	format+="${delimiter}"
	format+="#{window_index}"
	format+="${delimiter}"
	format+=":#{window_name}"
	format+="${delimiter}"
	format+="#{window_active}"
	format+="${delimiter}"
	format+=":#{window_flags}"
	format+="${delimiter}"
	format+="#{window_layout}"
	echo "$format"
}

# Get all the session from tmux
if [ $# -lt 1 ]; then
    mapfile -t SESSIONS < <(tmux list-sessions -F "#{session_name}")
else
    SESSIONS=("$@")
fi

echo ${SESSIONS[@]}

for ses in ${SESSIONS[@]}; do
	store_session $ses
done
