#!/bin/sh
#
# Automates snapshot upgrades a little bit

V="55"
CHKSUMS="SHA256.sig SHA256"
KERNELS="bsd bsd.mp bsd.rd"
EXTRACT_TARBALLS="comp${V}.tgz man${V}.tgz game${V}.tgz xbase${V}.tgz xserv${V}.tgz xshare${V}.tgz xfont${V}.tgz base${V}.tgz"
TARBALLS="${EXTRACT_TARBALLS} etc${V}.tgz xetc${V}.tgz"
#UPGRADE_PATH=/famholst/openbsd/snapshots/$(uname -m)/
UPGRADE_PATH=~/.openbsd

# Just assume /etc/pkg.conf is authorative with regard to
# path, machine type and version/snapshot.
OS_PATH=$(grep ^installpath /etc/pkg.conf | sed 's/packages\///g' | awk '{ print $3 }')

mkdir -p $UPGRADE_PATH
echo cd $UPGRADE_PATH 
cd $UPGRADE_PATH 

# Check for local copies of OpenBSD, otherwise get
# a copy
for i in $CHKSUMS $KERNELS $TARBALLS; do
#    if [ ! -f $i ]; then
        ftp -a ${OS_PATH}/$i
#    fi
done

sudo mount -uw /usr/local
sudo mount -uw /usr/X11R6

# copy kernel into place
echo New kernels ...
sudo cp bsd /bsd.sp
sudo cp bsd.mp bsd.rd /
if [ $(sysctl -n hw.ncpufound) -gt 1 ]; then
	echo Using bsd.mp
    sudo rm /obsd
    sudo ln /bsd /obsd && sudo cp /bsd.mp /nbsd && sudo mv /nbsd /bsd
else
	echo Using bsd
    sudo rm /obsd
    sudo ln /bsd /obsd && sudo cp /bsd.sp /nbsd && sudo mv /nbsd /bsd
fi

sudo cp /sbin/reboot /sbin/oreboot
echo Saved reboot binary. You should sudo -s now.

# extract relevant tarballs to root of drive, preserving permissions
for i in $EXTRACT_TARBALLS;
do
	echo -n "Untarring $i ... "
	sudo tar xzpf $i -C /
	echo "done."
done

# "Files to delete" from upgradeXY.html
if [ -f ~/bin/$(uname -r)rm.sh ]; then
        echo Scheduling file deletions 
        cat ~/bin/$(uname -r)rm.sh | sudo tee /etc/rc.firstrun
fi

# sysmerge
sudo sysmerge -b -s etc* -x xetc*
# XXX: Should  MAKEDEV all  be run by rc.firstrun?
cd /dev; sudo sh ./MAKEDEV all

# Install new bootblocks, like Han's upgrade script does
echo New bootblocks..
sudo cp /usr/mdec/boot /
cd /usr/mdec
rootdev=$(/bin/df /|sed  -ne 's|/dev/\(.*\)a.*|\1|p')
sudo ./installboot /boot ./biosboot $rootdev

# Package upgrade and remove obsolete dependencies
cd /tmp
sudo pkg_add -u
sudo pkg_delete -a

# Read-only partitions
sudo mount -ur /usr/local
sudo mount -ur /usr/X11R6
