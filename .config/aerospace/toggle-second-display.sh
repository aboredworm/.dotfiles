#!/bin/zsh
set -euo pipefail

display_uuid="DISPLAY_UUID"
aspace="$HOME/.local/bin/aspace"

notify() {
    osascript -e "display notification \"$1\" with title \"Display toggle\""
}

if ! display_state="$("$aspace" is-enabled "$display_uuid" 2>/dev/null)"; then
    notify "Reconnect the DISPLAY_MODEL once to register it"
    exit 1
fi

if [[ "$display_state" == "on" ]]; then
    if "$aspace" disable "$display_uuid"; then
        notify "DISPLAY_MODEL disabled"
    else
        notify "Could not disable DISPLAY_MODEL"
        exit 1
    fi
else
    if "$aspace" enable "$display_uuid"; then
        notify "DISPLAY_MODEL enabled"
    else
        notify "Could not enable DISPLAY_MODEL"
        exit 1
    fi
fi
