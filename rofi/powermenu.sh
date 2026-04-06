#!/usr/bin/env bash

# Icons
lock="󰌾"
hibernate="󰒲"
suspend="󰤄"
reboot="󰜉"
shutdown="󰐥"

options="$lock\n$hibernate\n$suspend\n$reboot\n$shutdown"

# Launch Rofi (Ensure this path to your .rasi is correct!)
chosen="$(echo -e "$options" | rofi -dmenu -theme "$HOME/.config/rofi/powermenu.rasi")"

case $chosen in
    $lock)
        /run/current-system/sw/bin/hyprlock
        ;;
    $hibernate)
        /run/current-system/sw/bin/systemctl hibernate
        ;;
    $suspend)
        /run/current-system/sw/bin/systemctl suspend
        ;;
    $reboot)
        /run/current-system/sw/bin/systemctl reboot
        ;;
    $shutdown)
        /run/current-system/sw/bin/systemctl poweroff
        ;;
esac