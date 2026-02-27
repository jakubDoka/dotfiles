#!/bin/sh

# Read current repeat_rate from the first keyboard
RATE=$(swaymsg -t get_inputs | jq -r '
  .[] | select(.type=="keyboard") | .repeat_rate' | head -n1)

if [ "$RATE" = "0" ]; then
  swaymsg input type:keyboard repeat_delay 300
  swaymsg input type:keyboard repeat_rate 30
else
  swaymsg input type:keyboard repeat_rate 0
fi
