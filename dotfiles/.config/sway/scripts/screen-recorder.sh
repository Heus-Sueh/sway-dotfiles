#!/usr/bin/env bash
# Make bash more sane
set -euo pipefail

theme="~/.config/rofi/screen-recorder.rasi"
rofi_command="rofi -theme $theme"
dir="$HOME/Videos/Screen-Recorder"
mkdir -p "$dir"

# Define the filename format
time=$(date +%Y-%m-%d-%I-%M-%S)
file="Recording_${time}.mp4"
pid_file="$dir/record.pid"

# Icons
icon1="$HOME/.config/dunst/icons/collections.svg"
icon2="$HOME/.config/dunst/icons/timer.svg"

# Buttons
screen=" Record Desktop"
area=" Record A Area"
infive="靖 Record in 3s"
inten="福 Record in 10s"
stop=" Stop Recording"

# Check if wf-recorder is active
check_recording() {
	if ps aux | grep -q '[w]f-recorder'; then
		return 0 # wf-recorder is active
	else
		return 1 # wf-recorder is not active
	fi
}

# Notify function
notify_view() {
	dunstify -u low --replace=699 -i "$icon1" "Recording started."
}

# Stop recording function
stop_recording() {
	if check_recording; then
		pkill -SIGINT wf-recorder # Send SIGINT to stop wf-recorder
		rm "$pid_file"            # Remove pid file
		dunstify -u low --replace=699 -i "$icon1" "Recording stopped."
	else
		dunstify -u low --replace=699 -i "$icon1" "No recording in progress."
	fi
}

# countdown
countdown() {
	for sec in $(seq "$1" -1 1); do
		dunstify -t 1000 --replace=699 -i "$icon2" "Recording starts in : $sec"
		sleep 1
	done
}

# Start recording functions
recordnow() {
	if check_recording; then
		# Recording is already active, offer to stop
		chosen="$(echo -e "Stop Recording" | $rofi_command -p 'Recording in progress' -dmenu)"
		case $chosen in
		"Stop Recording")
			stop_recording
			;;
		esac
	else
		# Start new recording
		wf-recorder -f "$dir/$file" &
		echo $! >"$pid_file"
		notify_view
	fi
}

record5() {
	countdown '3'
	recordnow
}

record10() {
	countdown '10'
	recordnow
}

recordarea() {
	if check_recording; then
		# Recording is already active, offer to stop
		chosen="$(echo -e "Stop Recording" | $rofi_command -p 'Recording in progress' -dmenu)"
		case $chosen in
		"Stop Recording")
			stop_recording
			;;
		esac
	else
		wf-recorder -f "$dir/$file" -g "$(slurp)" &
		echo $! >"$pid_file"
		notify_view
	fi
}

# Variable passed to rofi
options="$screen\n$area\n$infive\n$inten\n$stop"

chosen="$(echo -e "$options" | $rofi_command -p 'Start Recording' -dmenu -selected-row 0)"
case $chosen in
$screen)
	recordnow
	;;
$area)
	recordarea
	;;
$infive)
	record5
	;;
$inten)
	record10
	;;
$stop)
	stop_recording
	;;
esac
