#!/bin/bash
declare -A icons=(
  ["codium"]=""
  ["kitty"]=""
  ["firefox"]=""
)
DEFAULT_ICON=""

print_apps() {
  active_ws_id=$(hyprctl -j activeworkspace | jq '.id')
  clients=$(hyprctl -j clients)

  output="["
  first=true

  while read -r class; do
    if [ -z "$class" ]; then continue; fi

    class_lower=$(echo "$class" | tr '[:upper:]' '[:lower:]' | tr -d '\r\n')
    icon="${icons[$class_lower]:-$DEFAULT_ICON}"

    if [ "$first" = true ]; then
      first=false
    else
      output+=","
    fi
    output+=$(jq -n -c --arg class "$class" --arg icon "$icon" '{"class":$class, "icon":$icon}')
  done < <(echo "$clients" | jq -r ".[] | select(.workspace.id == $active_ws_id) | .class")

  output+="]"
  echo "$output"
}

# Print initial state
print_apps

# Listen for Hyprland events and reprint
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
  if [[ "$line" =~ ^(workspace|focusedmon|openwindow|closewindow|movewindow|activewindow) ]]; then
    print_apps
  fi
done
