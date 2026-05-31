
STASH_PATH="$HOME/.local/share/tmux/tmux-stash"
delimiter=$'\u001F'

RESTORABLE_COMMANDS="$(tmux show-option -gv @tmux-stash-restoreable-commands)"
if [[ $RESTORABLE_COMMANDS == "" ]]; then
    RESTORABLE_COMMANDS="nvim air 'pnpm run' 'npm run' 'bun run' 'cargo run'"
fi

# This checks if a given command is allowed to execute by checking if it's on a whitelist
# Returns "Enter" or ""
is_allowed_to_execute() {
    local cmd="$*"
    cmd="${cmd#/bin/bash }"
    cmd="${cmd#/bin/sh }"
    cmd="${cmd#/usr/bin/env }"
    if [[ "$cmd" == /* ]]; then # convert first argument to just basename
        local binary args
        binary=$(echo "$cmd" | cut -d' ' -f1)
        args=$(echo "$cmd" | cut -d' ' -f2-)
        cmd="$(basename $binary) $args"
    fi
    local -a commands
    eval "commands=($RESTORABLE_COMMANDS)"
    for allowed in "${commands[@]}"; do
        if [[ "$cmd" == "$allowed"* ]]; then
            echo "Enter"
            return
        fi
    done
    echo ""
    return
}
