#!/usr/bin/env bash

get_brightness() {
    xrandr --verbose | grep -w "$1" -a8 | grep 'Brightness:' | cut -f2- -d: | sed 's/ //'
}

list_displays() {
    echo 'displays:'
    displist=''
    connected=$(xrandr | grep -w connected | cut -f1 -d' ')
    for display in $connected; do
        brightness=$(get_brightness "$display")
        if [ -z "$brightness" ]; then
            displist+="$display: no brightness"
        else
            percentage=$(echo "$brightness * 100" | bc)
            displist+="$display: $percentage% brightness"
        fi
        displist+=$'\n'
    done
    echo "$displist" | column -t | sed 's/^/  /'
}

display_usage() {
    script_name=$(basename "$0")
    echo "Usage: $script_name op display [stepsize]"
    echo
    echo 'arguments:'
    echo '  op:             '-' to decrease or '+' to increase brightness'
    echo '  display:        name of a connected display to adjust'
    echo '  stepsize:       size of adjustment step (default 0.1)'
    echo
    list_displays 
}

if [[ "$1" = '+'  ||  "$1" = '-'  ]] && [[ -n "$2" ]]; then
    OP=$1
    DISP=$2
else
    display_usage
    exit 1
fi

if [[ "$3" =~ ^[0-9]+(.[0-9]+)?$ ]]; then
    STEPSIZE=$3
else
    STEPSIZE='0.1'
fi

CURRBRIGHT=$(get_brightness "$DISP")

if [[ ! "$CURRBRIGHT" =~ ^[0-9]+.[0-9]+$ ]]; then
    echo "Error: Selected display $DISP has no brightness value!"
    echo
    list_displays
    exit 1
fi

if [ "$OP" = '+' ]; then
   NEWBRIGHT=$(echo "$CURRBRIGHT + $STEPSIZE" | bc)
   if [ $(echo "$NEWBRIGHT > 1.0" | bc) -eq 1 ]; then
       NEWBRIGHT='1.0'
   fi
elif [ "$OP" = '-' ]; then
   NEWBRIGHT=$(echo "$CURRBRIGHT - $STEPSIZE" | bc)
   if [ $(echo "$NEWBRIGHT < 0.0" | bc) -eq 1 ]; then
       NEWBRIGHT='0.0'
   fi
fi

xrandr --output "$DISP" --brightness "$NEWBRIGHT"
