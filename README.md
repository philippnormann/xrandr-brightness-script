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
