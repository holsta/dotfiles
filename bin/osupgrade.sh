#!/bin/sh
#
# Automates snapshot upgrades a little bit

EXTRACT_TARBALLS="comp* man* game* base* xbase* xserv* xshare* xfont*"

if [ -d /famholst/openbsd/snapshots/$(uname -m)/ ]; then
	cd /famholst/openbsd/snapshots/$(uname -m)/

	# copy kernel into place
	echo New kernels ...
	sudo cp bsd bsd.mp bsd.rd /
	sudo config -ef /bsd << end-of-config
	disable apm
	quit
end-of-config

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

else
	echo warning: snapshot not available via NFS. 
	REMOTE=ssh files.mongers.org
	for i in $EXTRACT_TARBALLS;
	do
		$REMOTE 'cat $i' | sudo tar xzpf - -C /
	done
fi

