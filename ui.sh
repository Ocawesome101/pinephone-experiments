#!/bin/bash
# ui.sh: Start the UI

# Turn off TTY1's cursor
printf "\e[?25l\e[?1c" > /dev/tty1

sudo lua utils/modemnotifs.lua &

lua utils/uibase.lua
