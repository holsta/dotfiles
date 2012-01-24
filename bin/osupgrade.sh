#!/bin/sh
#
# Automates snapshot upgrades a little bit

EXTRACT_TARBALLS="comp* man* game* base* xbase* xserv* xshare* xfont*"
#UPGRADE_PATH=/famholst/openbsd/snapshots/$(uname -m)/
UPGRADE_PATH=/tmp/openbsd
SSH_HOST="files.mongers.org"

echo cd $UPGRADE_PATH 
cd $UPGRADE_PATH 

# Don't bother upgrading if the mirror holds a kernel
# identical to the installed kernel.
if [ ! $(diff -q /bsd $UPGRADE_PATH/bsd) ]; then
	echo Mirrored kernel unchanged.
	exit 1
fi

sudo mount -uw /usr
sudo mount -uw /usr/local
sudo mount -uw /usr/X11R6

# copy kernel into place
echo New kernels ...
sudo cp bsd bsd.mp bsd.rd /

sudo cp /sbin/reboot /root/reboot.$(uname -r)
echo Saved reboot binary. You should sudo -s now.
echo Also, make sure /etc/pkg.conf points to somewhere sane

# extract relevant tarballs to root of drive, preserving permissions
for i in $EXTRACT_TARBALLS;
do
	echo -n "Untarring $i ... "
	sudo tar xzpf $i -C /
	echo "done."
done

# sysmerge
sudo sysmerge -b -s etc*
sudo sysmerge -b -x xetc*
cd /dev; sudo sh ./MAKEDEV all

# Package upgrade and remote obsolete dependencies
cd /tmp
sudo pkg_add -ui
sudo pkg_delete -a

# Read-only partitions
sudo mount -ur /usr
sudo mount -ur /usr/local
sudo mount -ur /usr/X11R6
