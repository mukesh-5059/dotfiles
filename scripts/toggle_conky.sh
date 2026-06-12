#!/bin/bash

# Toggle Conky system monitor configurations

if pgrep -x conky >/dev/null; then
  echo "Conky is running. Killing it..."
  killall conky
else
  echo "Conky is not running. Starting sidebar monitor..."
  conky -c ~/modified-zenities/.config/conky/conky_sidebar.conf &
fi
