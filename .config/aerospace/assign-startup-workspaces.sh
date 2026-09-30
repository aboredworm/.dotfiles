#!/bin/zsh

aerospace_bin="$(command -v aerospace)"
[[ -x "$aerospace_bin" ]] || exit 0

for _ in {1..30}; do
    "$aerospace_bin" list-windows --all --format '%{window-id} %{app-bundle-id} %{workspace}' 2>/dev/null |
        while read -r window_id app_id current_workspace; do
            case "$app_id" in
                org.alacritty) target_workspace=1 ;;
                com.google.Chrome) target_workspace=2 ;;
                com.tinyspeck.slackmacgap) target_workspace=3 ;;
                com.anthropic.claudefordesktop) target_workspace=5 ;;
                md.obsidian) target_workspace=7 ;;
                com.brave.Browser) target_workspace=9 ;;
                *) continue ;;
            esac

            [[ "$current_workspace" == "$target_workspace" ]] && continue
            "$aerospace_bin" move-node-to-workspace --window-id "$window_id" -- "$target_workspace" >/dev/null 2>&1
        done

    sleep 1
done
