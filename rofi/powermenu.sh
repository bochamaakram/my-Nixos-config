lock="󰌾"
aquarium="󰈺" 
suspend="󰤄"
reboot="󰜉"
shutdown="󰐥"

options="$lock\n$aquarium\n$suspend\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | rofi -dmenu -theme "$HOME/.config/rofi/powermenu.rasi")"

case $chosen in
    $lock)
        loginctl lock-session
        ;;
    $aquarium)
        ~/.config/rofi/aquarium_screensaver.sh
        ;;
    $suspend)
        systemctl suspend
        ;;
    $reboot)
        systemctl reboot
        ;;
    $shutdown)
        systemctl poweroff
        ;;
esac