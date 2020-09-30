#!/usr/bin/env bash
set -e

if ! command -v bc &> /dev/null
then
    echo "bc command could not be found, it's needed to run this script."
    exit
fi

get_display_info() {
    xrandr --verbose | grep -m 1 -w "$1 connected" -A8 | grep "$2" | cut -f2- -d: | tr -d ' '
}

# cribbed from redshift, https://github.com/jonls/redshift/blob/master/README-colorramp
GAMMA_VALS=('1.0:0.7:0.4'  # 3000K
            '1.0:0.7:0.5'  # 3500K
            '1.0:0.8:0.6'  # 4000K
            '1.0:0.8:0.7'  # 4500K
            '1.0:0.9:0.8'  # 5000K
            '1.0:0.9:0.9'  # 6000K
            '1.0:1.0:1.0'  # 6500K
            '0.9:0.9:1.0'  # 7000K
            '0.8:0.9:1.0'  # 8000K
            '0.8:0.8:1.0'  # 9000K
            '0.7:0.8:1.0') # 10000K

get_gamma_index() {
    for i in "${!GAMMA_VALS[@]}"; do
        [[ "${GAMMA_VALS[$i]}" = "$1" ]] && echo "$i" && break
    done
}

get_temp_for_gamma() {
    idx=$(get_gamma_index "$1")
    awk '{printf "%.1f", $1 / 10}' <<< "$idx"
}

get_gamma_for_temp() {
    idx=$(awk '{printf "%d", $1 * 10}' <<< "$1")
    echo "${GAMMA_VALS[$idx]}"
}

# gamma values returned by xrandr --verbose are somehow inverted
# https://gitlab.freedesktop.org/xorg/app/xrandr/issues/33
# this function corrects this bug by reverting the calculation
invert_gamma() {
    inv_r=$(cut -d: -f1 <<< "$1")
    inv_g=$(cut -d: -f2 <<< "$1")
    inv_b=$(cut -d: -f3 <<< "$1")
    r=$(awk '{printf "%.1f", 1/$1}' <<< "$inv_r" 2>/dev/null)
    g=$(awk '{printf "%.1f", 1/$1}' <<< "$inv_g" 2>/dev/null)
    b=$(awk '{printf "%.1f", 1/$1}' <<< "$inv_b" 2>/dev/null)
    echo "$r:$g:$b"
}

get_gamma() {
    invert_gamma "$(get_display_info "$1" 'Gamma: ')"
}

get_brightness() {
    get_display_info "$1" 'Brightness: '
}

list_displays() {
    echo 'displays:'
    displist=''
    connected=$(xrandr | grep -w connected | cut -f1 -d' ')
    for display in $connected; do
        brightness=$(get_brightness "$display")
        gamma=$(get_gamma "$display")
        temp=$(get_temp_for_gamma "$gamma")
        displist+="$display brightness: $brightness gamma: $gamma temp: $temp"
        displist+=$'\n'
    done
    echo "$displist" | column -t | sed 's/^/  /'
}

display_usage() {
    script_name=$(basename "$0")
    echo "Usage: $script_name op display [stepsize|value] [--temp]"
    echo
    echo 'arguments:'
    echo '  op:             '-' to decrease or '+' to increase brightness'
    echo '                  '=' to set brightness to a specific value'
    echo '  display:        name of a connected display to adjust'
    echo '  stepsize:       size of adjustment step (default 0.1)'
    echo '  value:          value to set (default 1.0 for brightness, 0.6 for color temperature)'
    echo '  --temp:         adjusts color temperature instead of brightness'
    echo
    list_displays 
}

exec_op() {
    if [ "$1" = '+' ]; then
        NEWVAL=$(echo "$3 + $2" | bc)
    elif [ "$1" = '-' ]; then
        NEWVAL=$(echo "$3 - $2" | bc)
    elif [ "$1" = '=' ]; then
        NEWVAL=$2
    fi
    if [ "$(echo "$NEWVAL < 0.0" | bc)" -eq 1 ]; then
        NEWVAL='0.0'
    fi
    if [ "$(echo "$NEWVAL > 1.0" | bc)" -eq 1 ]; then
        NEWVAL='1.0'
    fi
    echo "$NEWVAL"
}

if [[ "$1" = '+'  ||  "$1" = '-' || "$1" = '=' ]] && [[ -n "$2" ]]; then
    OP=$1; DISP=$2; shift; shift
else
    display_usage; exit 1
fi

if [[ "$1" =~ ^[0-9]+(.[0-9]+)?$ ]]; then
    OPVAL=$1; shift
else
    if [[ "$OP" = '=' ]]; then
        if [[ "$1" = '--temp' ]]; then
            OPVAL='0.6'
        else
            OPVAL='1.0'
        fi
    else
        OPVAL='0.1'
    fi
fi

CURRBRIGHT=$(get_brightness "$DISP")
if [[ ! "$CURRBRIGHT" =~ ^[0-9]+.[0-9]+$ ]]; then
    echo "Error: Selected display $DISP has no brightness value!"
    echo; list_displays; exit 1
fi

CURRGAMMA=$(get_gamma "$DISP")
if [[ ! "$CURRGAMMA" =~ ^[0-9].[0-9]:[0-9].[0-9]:[0-9].[0-9]$ ]]; then
    echo "Error: Selected display $DISP has no gamma value!"
    echo; list_displays; exit 1
fi

NEWBRIGHT="$CURRBRIGHT"
NEWGAMMA="$CURRGAMMA"

if [ "$1" = '--temp' ]; then
    CURRTEMP=$(get_temp_for_gamma "$CURRGAMMA")
    NEWTEMP=$(exec_op "$OP" "$OPVAL" "$CURRTEMP")
    NEWGAMMA=$(get_gamma_for_temp "$NEWTEMP")
else
    NEWBRIGHT=$(exec_op "$OP" "$OPVAL" "$CURRBRIGHT")
fi

xrandr --output "$DISP" --brightness "$NEWBRIGHT" --gamma "$NEWGAMMA"
