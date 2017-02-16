# xrandr-brightness-script
Convinient script for adjusting the brightness of a display using xrandr.

Especially useful for OLED screens that don't have adjustable hardware backlights.

I recommend binding this script to custom keyboard shortcuts for easy accessibility.

## Usage:
```sh

./brightness.sh + eDP1     Increase brightness of eDP1 display by 0.1
./brightness.sh - eDP1     Decrease brightness of eDP1 display by 0.1
```
You can identify your display by running the `xrandr` command.

The first display on that list is usually the main display.

## Motivation;

My motivation for creating this little script was a problem my friend was having with his new HP Spectre x360 OLED under Linux.
He wasn't able to adjust the display brightness via the designated brightness keys on his keyboard. So I wrote this script for him and thought maybe others with similar problems could profit from me publishing this.
