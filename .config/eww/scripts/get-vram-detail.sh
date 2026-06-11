#!/bin/bash
used_bytes=$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || echo 0)
echo "$(( used_bytes / 1024 / 1024 ))MB"
