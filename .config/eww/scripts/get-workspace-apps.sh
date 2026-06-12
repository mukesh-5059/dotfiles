#!/bin/bash
declare -A icons=(
  # Browsers
  ["zen"]=""
  ["zen-browser"]=""
  ["zen-alpha"]=""
  ["firefox"]=""
  ["firefox-developer-edition"]=""
  ["firefox-esr"]=""
  ["google-chrome"]=""
  ["google-chrome-stable"]=""
  ["chromium"]=""
  ["brave-browser"]=""
  ["microsoft-edge"]=""
  ["microsoft-edge-stable"]=""
  ["opera"]=""
  ["vivaldi"]=""
  ["tor-browser"]=""
  ["torbrowser"]=""

  # Terminals
  ["kitty"]=""
  ["alacritty"]=""
  ["foot"]=""
  ["footclient"]=""
  ["wezterm"]=""
  ["gnome-terminal"]=""
  ["konsole"]=""
  ["xfce4-terminal"]=""
  ["termite"]=""

  # File Managers / Archivers
  ["org.gnome.nautilus"]="󰉋"
  ["nautilus"]="󰉋"
  ["thunar"]="󰉋"
  ["nemo"]="󰉋"
  ["dolphin"]="󰉋"
  ["pcmanfm"]="󰉋"
  ["pcmanfm-qt"]="󰉋"
  ["ranger"]="󰉋"
  ["yazi"]="󰇥"
  ["ark"]="󰉋"
  ["file-roller"]="󰉋"
  ["doublecmd"]="󰉋"

  # Editors & IDEs
  ["codium"]="󰨞"
  ["vscodium"]="󰨞"
  ["code"]="󰨞"
  ["vscode"]="󰨞"
  ["nvim"]=""
  ["neovim"]=""
  ["neovide"]=""
  ["vim"]=""
  ["gvim"]=""
  ["emacs"]=""
  ["sublime-text"]="󰨞"
  ["sublime_text"]="󰨞"
  ["subl"]="󰨞"
  ["android-studio"]="󰨞"
  ["intellij-idea"]="󰨞"
  ["intellij-idea-community"]="󰨞"
  ["pycharm"]="󰨞"
  ["webstorm"]="󰨞"
  ["clion"]="󰨞"
  ["goland"]="󰨞"
  ["rider"]="󰨞"
  ["rustrover"]="󰨞"
  ["obsidian"]="󱓧"

  # Chat & Communication
  ["discord"]=""
  ["discord-831593107883032657"]=""
  ["vesktop"]=""
  ["webcord"]=""
  ["telegram-desktop"]=""
  ["telegram"]=""
  ["org.telegram.desktop"]=""
  ["slack"]=""
  ["whatsapp"]="󰖣"
  ["whatsapp-for-linux"]="󰖣"
  ["caprine"]="󰈎"
  ["signal"]="󰓎"
  ["signal-desktop"]="󰓎"
  ["zoom"]="󰕧"
  ["zoom.us"]="󰕧"
  ["teams"]="󰊻"
  ["microsoft-teams"]="󰊻"

  # Media & Music
  ["spotify"]=""
  ["spotify-client"]=""
  ["ncspot"]=""
  ["mpv"]="󰕼"
  ["vlc"]="󰕼"
  ["celluloid"]="󰕼"
  ["kdenlive"]="󰕼"
  ["audacity"]="󰎆"
  ["obs"]="󰑋"
  ["obs-studio"]="󰑋"
  ["com.obsproject.studio"]="󰑋"
  ["youtube-music"]="󰎆"
  ["youtubemusic"]="󰎆"
  ["youtube music"]="󰎆"

  # Design & Graphics
  ["gimp"]="󰽉"
  ["gimp-2.99"]="󰽉"
  ["inkscape"]=""
  ["blender"]="󰂦"
  ["krita"]="󰽉"
  ["be.alexandervanhee.gradia"]="󰽉"

  # Image Viewers
  ["loupe"]="󰋩"
  ["eog"]="󰋩"
  ["viewnior"]="󰋩"
  ["gwenview"]="󰋩"
  ["sxiv"]="󰋩"
  ["nsxiv"]="󰋩"
  ["feh"]="󰋩"
  ["imv"]="󰋩"
  ["qview"]="󰋩"

  # System Utilities & Control
  ["pavucontrol"]="󰓃"
  ["org.pulseaudio.pavucontrol"]="󰓃"
  ["bluetuith"]="󰂯"
  ["blueman-manager"]="󰂯"
  ["blueman-adapters"]="󰂯"
  ["com.github.wwmm.easyeffects"]="󰓃"
  ["wiremix"]="󰓃"
  ["timeshift"]="󰆼"
  ["timeshift-gtk"]="󰆼"
  ["gparted"]="󰆼"
  ["gpartedbin"]="󰆼"
  ["btop"]="󰏗"
  ["htop"]="󰏗"
  ["gnome-system-monitor"]="󰏗"
  ["org.gnome.zenity"]="󰘳"
  ["zenity"]="󰘳"
  ["rofi"]="󰍉"
  ["localsend"]="󰱆"
  ["scrcpy"]="󰬬"
  ["flatseal"]="󰘳"

  # Office / Document Readers
  ["zathura"]="󰏆"
  ["evince"]="󰏆"
  ["onlyoffice"]="󰏆"
  ["onlyoffice-desktopeditors"]="󰏆"
  ["wps-office-wps"]="󰏆"
  ["wps-office-wpp"]="󰏆"
  ["wps-office-et"]="󰏆"
  ["wps-office-pdf"]="󰏆"
  ["wps"]="󰏆"
  ["wpp"]="󰏆"
  ["et"]="󰏆"
  ["libreoffice"]="󰏆"
  ["soffice"]="󰏆"
  ["libreoffice-writer"]="󰏆"
  ["libreoffice-calc"]="󰏆"
  ["libreoffice-impress"]="󰏆"
  ["komikku"]="󰏆"

  # Gaming & Game Engines
  ["steam"]="󰓓"
  ["steamwebhelper"]="󰓓"
  ["lutris"]="󰺵"
  ["heroic"]="󰺵"
  ["bottles"]="󰺵"
  ["sklauncher"]="󰺵"
  ["prismlauncher"]="󰺵"
  ["prism-launcher"]="󰺵"
  ["minecraft"]="󰺵"
  ["unityhub"]="󰚯"
  ["godot"]=""
  ["godot-editor"]=""
  ["virtualbox"]="󰢦"
  ["virtualbox manager"]="󰢦"
  ["dwarffortress"]="󰺵"
)
DEFAULT_ICON=""

print_apps() {
  active_ws_id=$(hyprctl -j activeworkspace | jq '.id')
  clients=$(hyprctl -j clients)

  output="["
  first=true

  while read -r class; do
    if [ -z "$class" ]; then continue; fi

    class_lower=$(echo "$class" | tr '[:upper:]' '[:lower:]' | tr -d '\r\n')
    icon="${icons[$class_lower]:-$DEFAULT_ICON}"

    # Fallback for flatpaks and standard apps with reverse-DNS names (e.g. net.lutris.Lutris)
    if [ "$icon" = "$DEFAULT_ICON" ] && [[ "$class_lower" == *.* ]]; then
      last_part="${class_lower##*.}"
      icon="${icons[$last_part]:-$DEFAULT_ICON}"
    fi

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
