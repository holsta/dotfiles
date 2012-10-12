#!/bin/sh
#
# Automates snapshot upgrades a little bit

EXTRACT_TARBALLS="comp* man* game* xbase* xserv* xshare* xfont* base*"
#UPGRADE_PATH=/famholst/openbsd/snapshots/$(uname -m)/
UPGRADE_PATH=/tmp/openbsd

# Just assume /etc/pkg.conf is authorative with regard to
# path, machine type and version/snapshot.
OS_PATH=$(grep ^installpath /etc/pkg.conf | sed 's/packages\///g' | awk '{ print $3 }')

mkdir -p $UPGRADE_PATH
echo cd $UPGRADE_PATH 
cd $UPGRADE_PATH 
ftp -a ${OS_PATH}"bsd*"

# Don't bother upgrading if the mirror holds a kernel
# identical to the installed kernel.
if [ ! $(diff -q /bsd.mp $UPGRADE_PATH/bsd.mp) -a 
	! $(diff -q /bsd.sp $UPGRADE_PATH/bsd) ]; 
	then
	echo Mirrored kernel unchanged.
	#exit 1
fi

# Remote kernel changed, get the rest.
ftp -a $OS_PATH*.tgz

sudo mount -uw /usr
sudo mount -uw /usr/local
sudo mount -uw /usr/X11R6

# copy kernel into place
echo New kernels ...
sudo cp bsd bsd.mp bsd.rd /
sudo cp bsd /bsd.sp
if [ $(sysctl -n hw.ncpufound) -gt 1 ]; then
	echo Using bsd.mp
	sudo cp /bsd.mp /bsd 
fi

sudo cp /sbin/reboot /root/reboot.$(uname -r)
echo Saved reboot binary. You should sudo -s now.

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

# Package upgrade and remove obsolete dependencies
cd /tmp
sudo pkg_add -ui
sudo pkg_delete -a

# Read-only partitions
sudo mount -ur /usr
sudo mount -ur /usr/local
sudo mount -ur /usr/X11R6
