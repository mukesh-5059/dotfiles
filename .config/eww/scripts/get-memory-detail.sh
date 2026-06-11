#!/bin/bash

# Get the used memory value from the 'free' command, in human-readable format
used_memory=$(free -h | awk '/Mem:/ {print $3}')

# Print the used memory
echo "$used_memory"

