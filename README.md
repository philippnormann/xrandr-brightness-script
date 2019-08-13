# xrandr-brightness-script
Convinient script for adjusting the brightness of a display using xrandr.

Especially useful for OLED screens that don't have adjustable hardware backlights.

I recommend binding this script to custom keyboard shortcuts for easy accessibility.

## Usage:

You can run `brightness.sh` to get a usage description and identify connected displays.

```sh
$ ./brightness.sh
Usage: brightness.sh op display [stepsize]

arguments:
  op:             - to decrease or + to increase brightness
  display:        name of a connected display to adjust
  stepsize:       size of adjustment step (default 0.1)

displays:
  eDP1:     100.0%  brightness
  HDMI-0:   100.0%  brightness
  DVI-D-0:  100.0%  brightness
```

### Examples:

```sh
$ ./brightness.sh + eDP1     Increase brightness of eDP1 display by 0.1
$ ./brightness.sh - eDP1     Decrease brightness of eDP1 display by 0.1
```

## Motivation:

My motivation for creating this little script was a problem my friend was having with his new HP Spectre x360 OLED under Linux.
He wasn't able to adjust the display brightness via the designated brightness keys on his keyboard. So I wrote this script for him and thought maybe others with similar problems could profit from me publishing this.
