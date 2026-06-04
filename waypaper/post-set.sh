#!/usr/bin/env bash

# The path to the wallpaper is passed as the first argument by waypaper
wallpaper="$1"

# Run pywal to generate the color palette
wal -i "$wallpaper"

# Run the Nix-shell script to update Discord colors
# Using the absolute path ensures it works no matter where Waypaper starts
/home/akram/walcord/update_discord.sh