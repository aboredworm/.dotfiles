#!/bin/zsh
set -euo pipefail

display_uuid_file="$HOME/.config/aerospace/display-uuid"
aspace="$HOME/.local/bin/aspace"

notify() {
    osascript -e "display notification \"$1\" with title \"Display toggle\""
}

if [[ ! -r "$display_uuid_file" ]]; then
    notify "Set the display UUID in ~/.config/aerospace/display-uuid"
    exit 1
fi

display_uuid="$(<"$display_uuid_file")"
if [[ -z "$display_uuid" ]]; then
    notify "The display UUID file is empty"
    exit 1
fi

if ! display_state="$("$aspace" is-enabled "$display_uuid" 2>/dev/null)"; then
    notify "Reconnect the display once to register it"
    exit 1
fi

if [[ "$display_state" == "on" ]]; then
    if "$aspace" disable "$display_uuid"; then
        notify "Display disabled"
    else
        notify "Could not disable display"
        exit 1
    fi
else
    if "$aspace" enable "$display_uuid"; then
        notify "Display enabled"
    else
        notify "Could not enable display"
        exit 1
    fi
fi
