#!/usr/bin/env bash

# EFFECTS FOR WINDOW TRANSPARENCY AND TRANSITIONS:
#   -cfF
#       c >> soft shadows and transparency support
#       f >> for fade in & out when opening and closing windows
#       F >> fade when changing a window's transparency
#
#   -t-9
#       shadows offset from top of window (9 pixels) & 11 pixels from left edge
#
#   -l-11
#       shadows offset from left of window (11 pixels)
#
#   -r9
#       shadow radius (9 pixels)
#
#   -0.95
#       shadow opacity (0.95)
#
#   -D6
#       time between each step when fading windows (6 milliseconds)

xcompmgr -cfF -t-9 -l-11 -r9 -o.95 -D6 &
