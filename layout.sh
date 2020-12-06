#!/usr/bin/env bash

# layout.sh:
#     Helper-script for configuring monitor layout.
#
# author: Everett
# created: 2020-11-02 17:36
# Github: https://github.com/antiqueeverett/

# -- display config
xrandr --output HDMI-0 --primary --mode 3440x1440 --pos 0x0 --rotate normal --output DP-0 --mode 3840x2160 --pos 3440x0 --rotate left --output DP-1 --off --output DP-2 --off --output DP-3 --off --output HDMI-1 --off --output USB-C-0 --off &

# -- manage wallpaper
nitrogen --restore &
sleep 0.2


# -- manage transitions and transparency effects
compton -f &

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
xcompmgr -cfF -t-5 -l-5 -r5 -o.95 -D10 &
