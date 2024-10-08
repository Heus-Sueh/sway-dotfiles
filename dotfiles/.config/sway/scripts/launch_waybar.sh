#!/bin/env bash

# Make bash more sane
set -euo pipefail

is_waybar_ServerExist=$(ps -ef | grep -m 1 waybar | grep -v "grep" | wc -l)
if [ "$is_waybar_ServerExist" = "0" ]; then
	echo "waybar_server not found" >/dev/null 2>&1
#	exit;
elif [ "$is_waybar_ServerExist" = "1" ]; then
	killall waybar
fi

for i in /sys/class/hwmon/hwmon*/temp*_input; do
	if [ "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*}))" = "coretemp: Core 0" ]; then
		export HWMON_PATH="$i"
	fi
done

themes="$HOME/.local/share/waybar/themes"
layout="$themes/catppuccin/layouts/layout3.jsonc"
style="$themes/catppuccin/styles/style3.css"

waybar -c $layout -s $style &
