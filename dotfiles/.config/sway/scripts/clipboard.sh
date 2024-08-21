#!/bin/env bash
# Make bash more sane
set -euo pipefail

fzf_args="fzf --prompt 'pick > ' --bind 'tab:up' --cycle --read0"

clipman pick --print0 -t CUSTOM -T "$fzf_args"
