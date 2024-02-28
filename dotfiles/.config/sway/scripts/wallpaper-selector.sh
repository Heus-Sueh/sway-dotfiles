#!/bin/bash
# This script is for selecting wallpapers (SUPER W)

ROFI_THEME="~/.local/share/rofi/wallpaper-selector.rasi"
sway_scripts="$HOME/.config/sway/scripts"

# WALLPAPERS PATH
wallDIR="$HOME/Pictures/Wallpapers"

# Check if swaybg is running
if pidof swaybg > /dev/null; then
  pkill swaybg
fi

# Retrieve image files (including subdirectories)
PICS=($(find "${wallDIR}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif \)))
RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME="${#PICS[@]}. random"

# Rofi command
rofi_command="rofi -dmenu -theme $ROFI_THEME"

menu() {
  printf "Random\n"
  for i in "${!PICS[@]}"; do
    # Displaying .gif to indicate animated images
    if [[ -z $(echo "${PICS[$i]}" | grep .gif$) ]]; then
      printf "$(basename "${PICS[$i]}" | cut -d. -f1)\x00icon\x1f${PICS[$i]}\n"
    else
      printf "$(basename "${PICS[$i]}" | cut -d. -f1)\n"
    fi
  done
}

main() {
  choice=$(menu | ${rofi_command})

  # No choice case
  if [[ -z $choice ]]; then
    exit 0
  fi

  # Random choice case
  if [ "$choice" = "Random" ]; then
    swaybg -i "${RANDOM_PIC}" &
    exit 0
  fi

  # Find the selected file
  selected_file=""
  for file in "${PICS[@]}"; do
    if [[ "$(basename "$file" | cut -d. -f1)" = "$choice" ]]; then
      selected_file="$file"
      break
    fi
  done

  if [[ -n "$selected_file" ]]; then
    swaybg -i "$selected_file" &
  else
    echo "Image not found."
    exit 1
  fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
  exit 0
fi

main

