#!/bin/bash
# ui.sh: Start the UI

sudo lua utils/modemnotifs.lua &

lua utils/uibase.lua
