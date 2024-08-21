#!/bin/env bash
# Make bash more sane
set -euo pipefail

# Actual code
FOCUSED_APP_ID=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true).pid')
kill -9 $FOCUSED_APP_ID
