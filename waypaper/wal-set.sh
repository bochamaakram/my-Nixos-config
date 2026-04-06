#!/usr/bin/env bash

# 1. Run pywal
wal -i "$1"

# 2. Update a symlink to the current wallpaper
# This creates a fixed path that hyprlock can always find
ln -sf "$1" "$HOME/.cache/current_wallpaper"
