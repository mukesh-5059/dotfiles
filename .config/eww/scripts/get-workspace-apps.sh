#!/bin/bash
declare -A icons=(
  ["codium"]=""
  ["kitty"]=""
  ["firefox"]=""
)
DEFAULT_ICON=""

active_ws_id=$(hyprctl -j activeworkspace | jq '.id')
clients=$(hyprctl -j clients)

output="["
first=true

while read -r class; do
  if [ -z "$class" ]; then continue; fi

  class_lower=$(echo "$class" | tr '[:upper:]' '[:lower:]')
  icon="${icons[$class_lower]:-$DEFAULT_ICON}"

  if [ "$first" = true ]; then
    first=false
  else
    output+=","
  fi
  output+=$(jq -n --arg class "$class" --arg icon "$icon" '{"class":$class, "icon":$icon}')
done < <(echo "$clients" | jq -r ".[] | select(.workspace.id == $active_ws_id) | .class")

output+="]"
echo "$output"
