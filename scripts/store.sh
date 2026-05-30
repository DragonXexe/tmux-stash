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
	local panes=$(tmux list-panes -a -f "#{==:#{session_name},$1}" -F "$(pane_format)")
	local windows=$(tmux list-windows -a -f "#{==:#{session_name},$1}" -F "$(window_format)")
	echo "$windows"
	echo "$panes"
}
pane_format() {
	local format
	format+="pane"
	format+="${delimiter}"
	format+="#{session_name}"
	format+="${delimiter}"
	format+="#{window_index}"
	format+="${delimiter}"
	format+="#{window_active}"
	format+="${delimiter}"
	format+=":#{window_flags}"
	format+="${delimiter}"
	format+="#{pane_index}"
	format+="${delimiter}"
	format+=":#{pane_current_path}"
	format+="${delimiter}"
	format+="#{pane_active}"
	format+="${delimiter}"
	format+="#{pane_current_command}"
	format+="${delimiter}"
	format+="#{pane_pid}"
	format+="${delimiter}"
	format+="#{history_size}"
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
