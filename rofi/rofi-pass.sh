#!/usr/bin/env bash

# Paths
DB_FILE="$HOME/.config/rofi/passwords.json"
ROFI_THEME="$HOME/.config/rofi/launcher.rasi"

# Ensure dependencies are available
if [ ! -f "$DB_FILE" ]; then
    dunstify -u low "Rofi Pass" "Database not found at $DB_FILE"
    exit 1
fi

while true; do
    # 1. Select the Account
    account_choice=$(jq -r 'keys[]' "$DB_FILE" | rofi -dmenu -i -p "󰌋 Passwords" -theme "$ROFI_THEME")

    # Exit if Escape is pressed
    if [ -z "$account_choice" ]; then
        exit 0
    fi

    while true; do
        # Get data for the selected account
        account_data=$(jq -r --arg key "$account_choice" '.[$key]' "$DB_FILE")

        # Format display (Masking password fields)
        # Adds "<- Back" as the first option
        display_list=$(echo "$account_data" | jq -r '
          to_entries | .[] | 
          if .key == "password" or .key == "pass" then 
            "\(.key): ********" 
          else 
            "\(.key): \(.value)" 
          end
        ')
        
        menu_content=$(echo -e "󰌍  Back\n$display_list")

        selected_line=$(echo "$menu_content" | rofi -dmenu -i -p "󰈚 $account_choice" -theme "$ROFI_THEME")

        # Navigation: If Escape or "Back" is selected, return to main list
        if [ -z "$selected_line" ] || [[ "$selected_line" == *"Back"* ]]; then
            break
        fi

        # 3. Extract the key (the part before the colon)
        field_key=$(echo "$selected_line" | cut -d':' -f1 | xargs)
        real_value=$(echo "$account_data" | jq -r --arg key "$field_key" '.[$key]')

        if [ "$real_value" != "null" ]; then
            echo -n "$real_value" | wl-copy
            
            # Dunst Notification with Replace ID (991) to prevent bubble stacking
            dunstify -u low -a "RofiPass" -i "edit-copy" -r 991 "Copied" "$field_key for $account_choice"
            
            # Clear clipboard after 30 seconds and update the same notification
            (
                sleep 30
                current_clip=$(wl-paste)
                if [ "$current_clip" == "$real_value" ]; then
                    wl-copy --clear
                    dunstify -u low -a "RofiPass" -i "edit-clear" -r 991 "Clipboard Cleared" "Sensitive data removed."
                fi
            ) &
            
            # Break back to account list after copying
            break
        fi
    done
done