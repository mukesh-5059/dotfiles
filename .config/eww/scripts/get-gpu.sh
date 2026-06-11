#!/bin/bash
cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || echo 0
