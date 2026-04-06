#!/bin/bash

# Options
screen="󰹑 Screen"
area="󰆞 Area"
window="󰖭 Window"

options="$screen\n$area\n$window"

# Using your existing Rofi theme or a simple one
chosen="$(echo -e "$options" | rofi -dmenu -i -p "Screenshot" -theme ~/.config/rofi/launcher.rasi)"

case $chosen in
    $screen)
        sleep 1 && grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%m-%s).png && notify-send "Screenshot Captured"
        ;;
    $area)
        grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%m-%s).png && notify-send "Area Captured"
        ;;
    $window)
        # Captures the active window using hyprctl
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%m-%s).png && notify-send "Window Captured"
        ;;
esac