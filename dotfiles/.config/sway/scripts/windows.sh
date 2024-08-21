#!/usr/bin/env bash
theme="~/.config/rofi/windows.rasi"
term="alacritty"

rofi \
	-show window \
	-modi run,drun,ssh \
	-scroll-method 0 \
	-drun-match-fields all \
	-drun-display-format "{name}" \
	-no-drun-show-actions \
	-terminal $term \
	-kb-cancel Escape \
	-theme $theme
