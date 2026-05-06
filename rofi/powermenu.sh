lock="󰌾"
suspend="󰤄"
reboot="󰜉"
shutdown="󰐥"

options="$lock\n$suspend\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | rofi -dmenu -theme "$HOME/.config/rofi/powermenu.rasi")"

case $chosen in
    $lock)
        loginctl lock-session
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