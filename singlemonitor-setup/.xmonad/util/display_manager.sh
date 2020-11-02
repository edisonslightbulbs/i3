#!/bin/sh

# wallpaper manager
#
nitrogen --restore


# transitions and transparency effects
#
compton -f


# EFFECTS FOR WINDOW TRANSPARENCY AND TRANSITIONS:
#
#   -cfF
#       c
#        soft shadows and transparency support
#       f
#        for fade in & out when opening and closing windows
#       F
#        fade when changing a window's transparency
#
#   -t-5
#       shadows offset from top of window (9 pixels) & 11 pixels from left edge
#
#   -l-5
#       shadows offset from left of window (11 pixels)
#
#   -r5
#       shadow radius (9 pixels)
#
#   -0.95
#       shadow opacity (0.95)
#
#   -D10
#       time between each step when fading windows (10 milliseconds)
xcompmgr -cfF -t-5 -l-5 -r5 -o.95 -D10
