#!/bin/sh

# A nice solid background colour, please
xsetroot -solid white 
# keyboard repeat rate 
xset r rate 250 60
# mouse speed
xset m 5 1

# if we can read or write to apmdev, only then run wmapm
if [ -w /var/run/apmdev ] || [ -r /var/run/apmdev ]; then
	[ -x /usr/local/bin/wmapm ] && wmapm &
fi

# Lock the display only when users requests, never on a timeout.
if [ -x /usr/X11R6/bin/xidle ]; then
	xidle -sw -timeout 0 & 
fi

exec /usr/X11R6/bin/cwm
