#!/bin/bash
used=$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || echo 0)
total=$(cat /sys/class/drm/card1/device/mem_info_vram_total 2>/dev/null || echo 1)
echo $(( used * 100 / total ))
