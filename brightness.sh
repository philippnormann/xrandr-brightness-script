#!/bin/sh
CURRBRIGHT=$(xrandr --current --verbose | grep -m 1 'Brightness:' | cut -f2- -d:)
if [ "$1" = "+" ] && [ $(echo "$CURRBRIGHT < 1" | bc) -eq 1 ] 
then
xrandr --output $2 --brightness $(echo "$CURRBRIGHT + 0.1" | bc)
elif [ "$1" = "-" ] && [ $(echo "$CURRBRIGHT > 0" | bc) -eq 1 ] 
then
xrandr --output $2 --brightness $(echo "$CURRBRIGHT - 0.1" | bc)
fi
