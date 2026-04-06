#!/bin/bash
# The path to the wallpaper is passed as the first argument by waypaper
wallpaper=$1

# Run pywal
wal -i "$wallpaper"

# Optional: Reload your WM or bar if they don't auto-update
# Example for sway/i3: 
# swapy msg reload
