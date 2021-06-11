#!/bin/bash

case "$1" in
  start)
    lua interface/drawthread.lua &
    lua interface/main.lua &
    ;;
  stop)
    pkill lua
    ;;
  *)
    echo "invalid argument"
    exit 1
    ;;
esac
