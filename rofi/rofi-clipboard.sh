#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/launcher.rasi"

rofi_cmd="rofi -dmenu -i -theme $ROFI_THEME -kb-custom-1 Alt+x"

while true; do
    # Get the list from cliphist and pipe to rofi
    choice=$(cliphist list | $rofi_cmd -p "Clipboard:")
    
    exit_code=$?

    # If user hits Escape
    if [ -z "$choice" ]; then
        exit 0
    fi

    if [ "$exit_code" -eq 10 ]; then
        # Shift+Delete pressed: Remove from history
        echo "$choice" | cliphist delete
        dunstify -u low -i "edit-paste" "Clipboard" "Item Deleted from history"
    elif [ "$exit_code" -eq 0 ]; then
        # Enter pressed: Copy to clipboard
        echo "$choice" | cliphist decode | wl-copy
        dunstify -u low -i "edit-paste" "Clipboard" "Item copied to clipboard"
        exit 0
    fi
done