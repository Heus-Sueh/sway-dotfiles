#!/bin/bash
# This script is for selecting wallpapers (SUPER T)
export PATH=$PATH:$HOME/.local/bin
ROFI_THEME="$HOME/.config/rofi/wallpaper-selector.rasi"
SWAY_SCRIPTS="$HOME/.config/sway/scripts"

# Path to wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Retrieve image files (including subdirectories)
PICS=($(find "${WALLPAPER_DIR}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif \)))
RANDOM_PIC="${PICS[RANDOM % ${#PICS[@]}]}"
RANDOM_PIC_NAME="${#PICS[@]}. random"

# Rofi command
rofi_command="rofi -dmenu -theme $ROFI_THEME"

# Function to generate the menu
menu() {
  printf "Random\n"
  for pic in "${PICS[@]}"; do
    # Display .gif to indicate animated images
    if [[ ! "${pic}" =~ \.gif$ ]]; then
      printf "$(basename "${pic}" | cut -d. -f1)\x00icon\x1f${pic}\n"
    else
      printf "$(basename "${pic}" | cut -d. -f1)\n"
    fi
  done
}

# Main function
main() {
  choice=$(menu | ${rofi_command})

  # Exit if no choice is made
  if [[ -z $choice ]]; then
    exit 0
  fi

  # Kill swaybg if running, only if a choice is made
  if pidof swaybg > /dev/null; then
    pkill swaybg
  fi

  # Handle random choice
  if [[ "$choice" == "Random" ]]; then
    sed -i '/^exec_always swaybg/d' ~/.config/sway/config 
    echo "# Rofi Wallpaper Selector" >> ~/.config/sway/config
    echo "exec_always swaybg -i $RANDOM_PIC -m fill" >> ~/.config/sway/config
    matugen image $RANDOM_PIC -m 'dark'
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    swaymsg reload
    exit 0
  fi

  # Find the selected file
  selected_file=""
  for file in "${PICS[@]}"; do
    if [[ "$(basename "$file" | cut -d. -f1)" == "$choice" ]]; then
      selected_file="$file"
      break
    fi
  done

  if [[ -n "$selected_file" ]]; then
    swaybg -i "$selected_file" &
    # Update sway config file
    sed -i '/^# Rofi Wallpaper/d' ~/.config/sway/config
    sed -i '/^exec_always swaybg/d' ~/.config/sway/config 
    echo "# Rofi Wallpaper Selector" >> ~/.config/sway/config
    echo "exec_always swaybg -i $selected_file -m fill" >> ~/.config/sway/config
    matugen image $selected_file -m 'dark'
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
    swaymsg reload
  else
    echo "Wallpaper not found."
    exit 1
  fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
  exit 0
fi

main
