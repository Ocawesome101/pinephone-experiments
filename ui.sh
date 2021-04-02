#!/bin/bash
# ui.sh: Start the UI

# Turn off TTY1's cursor
sudo chvt 1
printf "\e[?25l\e[?1c" | sudo tee /dev/tty1 > /dev/null

lua ui/modemnotifs.lua &

lua ui/base.lua
