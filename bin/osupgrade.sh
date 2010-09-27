#!/bin/sh
#
# Automates snapshot upgrades a little bit

EXTRACT_TARBALLS="base* comp* misc* man* game* xbase* xserv* xshare* xfont*"
etctemp=`mktemp -d`

cd /famholst/openbsd/snapshots/$(uname -m)/

# copy kernel into place
echo New kernels ...
sudo cp bsd bsd.mp bsd.rd /

# extract relevant tarballs to root of drive, preserving permissions
for i in $EXTRACT_TARBALLS;
	do 
	echo -n "Untarring $i ... "
	sudo tar xzpf $i -C /;
	echo "done."
done

# extract etcXY.tgz and blindly copy certain files into place
if [ -f /etc/unchangedfiles ]; then
	echo "Replacing unchanged files..."
	#sudo tar xzpf etc*.tgz -C $etctemp
	cd $etctemp

	while read unchanged; do
		echo cp $unchanged /
	done < /etc/unchangedfiles
fi

cd ~
rm -rf $etctemp
