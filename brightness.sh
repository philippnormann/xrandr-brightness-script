#!/bin/sh
# Author: Philipp Normann

# Script for adjusting brightness of laptop OLED displays using xrandr
# Especially useful for custom keyboard shortcuts

# Usage:
# ./brightness.sh + eDP1     Increase brightness of eDP1 display by 0.1
# ./brightness.sh - eDP1     Decrease brightness of eDP1 display by 0.1
#
# You can identify your display by running the "xrandr" command
# The first display on that list is usually the laptops main display

CURRBRIGHT=$(xrandr --current --verbose | grep 'Brightness:' | cut -f2- -d:)
if [ "$1" = "+" ] && [ $(echo "$CURRBRIGHT < 1" | bc) -eq 1 ] 
then
xrandr --output $2 --brightness $(echo "$CURRBRIGHT + 0.1" | bc)
elif [ "$1" = "-" ] && [ $(echo "$CURRBRIGHT > 0" | bc) -eq 1 ] 
then
xrandr --output $2 --brightness $(echo "$CURRBRIGHT - 0.1" | bc)
fi
