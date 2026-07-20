#!/bin/bash

# Define the target CSS file and the Rofi themes to use
script_dir="$HOME/.config/waybar/scripts/clock_calendar"
calendar_script="$script_dir/clock_calendar.sh"
# rofi menu
rofi_horizontal_menu="$HOME/.config/rofi/horizontal_menu.rasi"

# --- Main Menu ---
main_options="󰃭\u3000Event"
main_choice=$(echo -e "$main_options" | rofi -dmenu -mesg "<b>Waybar Clock Add</b>" -theme "$rofi_horizontal_menu")

# --- Handle the choice with a case statement ---
case "$main_choice" in
*"Even"*)
    $calendar_script --show-rofi
    ;;
*)
    exit 0
    ;;
esac
