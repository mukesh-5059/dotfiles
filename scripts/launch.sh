# WAYBAR START
#
# by Abuku (2024)

# Quit running eww bar instances
killall eww
killall wayneko
swaync-client -R
swaync-client -rs
# Start eww bar
eww open bar 
wayneko --layer top --width 1120 --margin-left 400 --margin-top 12

