#!/bin/env bash
# Make bash more sane
set -euo pipefail

# This script is for selecting wallpapers (Modifier + whatever)
export PATH=$PATH:$HOME/.local/bin
ROFI_THEME="$HOME/.config/rofi/wallpaper-selector.rasi"
SWAY_SCRIPTS="$HOME/.config/sway/scripts"

# Path to wallpapers
# WALLPAPER_DIR="$HOME/Pictures/Wallpapers/beautiful-wallpapers"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/wallhaven"

# Retrieve image files (including subdirectories)
PICS=($(find "${WALLPAPER_DIR}" -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png -o -iname \*.gif \)))
RANDOM_PIC="${PICS[RANDOM % ${#PICS[@]}]}"
RANDOM_PIC_NAME="${#PICS[@]}. random"

# List of all types:
# scheme-content
# scheme-expressive
# scheme-fidelity
# scheme-fruit-salad
# scheme-monochrome
# scheme-neutral
# scheme-rainbow
# scheme-tonal-spot

MODE="dark"
SCHEME_TYPE="scheme-fidelity"
MATUGEN_ARGS="-m $MODE -v -t $SCHEME_TYPE --show-colors --debug"

INTERFACE="org.gnome.desktop.interface"
WM_PREFERENCES="org.gnome.desktop.wm.preferences"

# SWAYBG_ARGS=
# SWWW_ARGS=
# HYPRPAPER_ARGS=
# MPVPAPER_ARGS=

# Rofi command
ROFI_COMMAND="rofi -dmenu -theme $ROFI_THEME"

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
	choice=$(menu | ${ROFI_COMMAND})

	# Exit if no choice is made
	if [[ -z $choice ]]; then
		exit 0
	fi

	# Kill swaybg if running, only if a choice is made
	if pidof swaybg >/dev/null; then
		pkill swaybg
	fi

	# Handle random choice
	if [[ "$choice" == "Random" ]]; then
		matugen image $RANDOM_PIC $MATUGEN_ARGS
		gsettings set $INTERFACE gtk-theme adw-gtk3-dark
		gsettings set $WM_PREFERENCES theme 'adw-gtk3-dark'
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
		matugen image $selected_file $MATUGEN_ARGS
		gsettings set $INTERFACE gtk-theme adw-gtk3-dark
		gsettings set $WM_PREFERENCES theme 'adw-gtk3-dark'
		swaymsg reload
	else
		echo "Wallpaper not found."
		exit 1
	fi
}

# Check if rofi is already running
if pidof rofi >/dev/null; then
	pkill rofi
	exit 0
fi

main
