#!/bin/bash

# Get CPU temperature (works on Ryzen systems with 'sensors' installed)
cpu_temp=$(sensors | grep Tctl | awk '{print $2}' | tr -d '+°C' | cut -d'.' -f1)

# Print the CPU temperature as an integer
echo "$cpu_temp"

