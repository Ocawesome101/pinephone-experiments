#!/bin/bash
# ui.sh: Start the UI

# Turn off TTY1's cursor
sudo chvt 1
printf "\e[?25l\e[?1c" > /dev/tty1

lua ui/modemnotifs.lua &

lua ui/base.lua
