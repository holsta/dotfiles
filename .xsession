#!/bin/sh
# $XConsortium: xinitrc.cpp,v 1.4 91/08/22 11:41:34 rws Exp $
# $Id: xsession,v 1.10 2008/01/19 21:13:50 holsta Exp $

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/usr/X11R6/lib/X11/xinit/.Xresources
sysmodmap=/usr/X11R6/lib/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
    xrdb -merge $userresources
fi

if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# A nice solid background colour, please
xsetroot -solid black
# keyboard repeat rate 
xset r rate 250 60
# mouse speed
xset m 5 1

# Support for powerful, remote appserver..
REMOTEAPPS="gimp inkscape firefox easytag audacity pidgin foo"

for i in $REMOTEAPPS; do
	if [ ! -x "`which $i`" ]; then
		alias $i='remoteapp $i'
	fi
done

remoteapp () {
        appname=$1
        apphost=appserver

        ssh -Y $apphost '$appname'
}

# if we can read or write to apmdev, only then run wmapm
if [ -w /var/run/apmdev ] || [ -r /var/run/apmdev ]; then
	[ -x /usr/local/bin/wmapm ] && wmapm &
fi

# Lock the display only when users requests, never on a timeout.
#if [ -x /usr/X11R6/bin/xidle ]; then
#	xidle -sw -timeout 0 & 
#fi

/usr/X11R6/bin/cwm
