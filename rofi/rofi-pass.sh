#!/usr/bin/env bash

# Paths
DB_FILE="$HOME/.config/rofi/passwords.json"
ROFI_THEME="$HOME/.config/rofi/launcher.rasi"

# --- ROOT AUTHENTICATION ---
# This uses a loop to ensure the user actually enters the correct password
if ! sudo -v -n 2>/dev/null; then
    # Prompt for password via Rofi
    pass=$(rofi -dmenu -password -p " Root Password Required" -theme "$ROFI_THEME")
    
    # If user pressed Escape
    [ -z "$pass" ] && exit 1

    # Check if the password is correct
    if ! echo "$pass" | sudo -S -v &>/dev/null; then
        dunstify -u critical -a "RofiPass" "Authentication Failed" "Incorrect password."
        exit 1
    fi
fi
# ---------------------------

# Ensure dependencies/file are available
if [ ! -f "$DB_FILE" ]; then
    echo "{}" > "$DB_FILE"
fi

while true; do
    accounts=$(jq -r 'keys[]' "$DB_FILE")
    menu_main=$(echo -e "󰏐  Add New Account\n$accounts")
    
    account_choice=$(echo "$menu_main" | rofi -dmenu -i -p "󰌋 Passwords" -theme "$ROFI_THEME")

    if [ -z "$account_choice" ]; then
        exit 0
    fi

    # ADD NEW ACCOUNT LOGIC
    if [[ "$account_choice" == *"Add New Account"* ]]; then
        new_name=$(rofi -dmenu -p "Account Name:" -theme "$ROFI_THEME")
        [ -z "$new_name" ] && continue

        new_user=$(rofi -dmenu -p "Username:" -theme "$ROFI_THEME")
        new_pass=$(rofi -dmenu -p "Password:" -theme "$ROFI_THEME")

        tmp_db=$(mktemp)
        jq --arg name "$new_name" \
           --arg user "$new_user" \
           --arg pass "$new_pass" \
           '.[$name] = {"username": $user, "password": $pass}' "$DB_FILE" > "$tmp_db" && mv "$tmp_db" "$DB_FILE"

        dunstify -u low -a "RofiPass" "Success" "Added $new_name to database"
        continue
    fi

    # VIEW/COPY LOGIC
    while true; do
        account_data=$(jq -r --arg key "$account_choice" '.[$key]' "$DB_FILE")

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

        if [ -z "$selected_line" ] || [[ "$selected_line" == *"Back"* ]]; then
            break
        fi

        field_key=$(echo "$selected_line" | cut -d':' -f1 | xargs)
        real_value=$(echo "$account_data" | jq -r --arg key "$field_key" '.[$key]')

        if [ "$real_value" != "null" ]; then
            echo -n "$real_value" | wl-copy
            dunstify -u low -a "RofiPass" -i "edit-copy" -r 991 "Copied" "$field_key for $account_choice"
            
            (
                sleep 30
                current_clip=$(wl-paste)
                if [ "$current_clip" == "$real_value" ]; then
                    wl-copy --clear
                    dunstify -u low -a "RofiPass" -i "edit-clear" -r 991 "Clipboard Cleared" "Sensitive data removed."
                fi
            ) &
            break
        fi
    done
done