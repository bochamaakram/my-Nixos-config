#!/usr/bin/env bash

# 1. Define the pywal color file path
WAL_COLORS="source = $HOME/.cache/wal/colors-hyprland.conf"

# 2. Check if asciiquarium and pywal colors exist
if ! command -v asciiquarium &> /dev/null; then
    echo "Error: asciiquarium not found."
    exit 1
fi

if [ ! -f "$WAL_COLORS" ]; then
    echo "Warning: Pywal colors not found at $WAL_COLORS. Using default colors."
    # We'll set a fallback or just proceed
    WAL_ARG=""
else
    # This tells Kitty to load the pywal colors specifically
    WAL_ARG="--config=$WAL_COLORS"
fi

# 3. Launch Kitty
# We remove --config NONE and replace it with the pywal config
# We use -o to override specific behaviors we still want
kitty --class "fish_screensaver" \
      $WAL_ARG \
      -o "confirm_os_window_close=0" \
      -o "cursor_stop_blinking=true" \
      -o "window_padding_width=0" \
      --start-as=fullscreen \
      bash -c "sleep 0.2; asciiquarium" &

# Give it a moment to initialize
sleep 0.6

# 4. Get initial mouse position
START_POS=$(hyprctl cursorpos)

# 5. Wait for activity
while true; do
    CURRENT_POS=$(hyprctl cursorpos)
    
    if [ "$CURRENT_POS" != "$START_POS" ]; then
        break
    fi

    if ! pgrep -f "fish_screensaver" > /dev/null; then
        break
    fi

    sleep 0.1
done

# 6. Cleanup
pkill -f "fish_screensaver"