#!/bin/sh
#
# Automates snapshot upgrades a little bit

test -n "$OS_PATH" || (echo "OS_PATH not set; exiting"; exit 1)

DOWNLOAD="base* bsd* comp* etc* misc* man* game* x* pxeboot"
EXTRACT_TARBALLS="base* comp* misc* man* game* xbase* xserv* xshare* xfont*"
test -z $tempdl && tempdl=`mktemp -d`
etctemp=`mktemp -d`

mkdir -p $tempdl
cd $tempdl 
echo Downloading to $tempdl

for file in $DOWNLOAD; do
	echo "Getting $file"
	ftp -4Va $OS_PATH/$file || (echo 'ftp failed; exiting'; rm -rf $tempdl; exit 1)
done

# copy kernel into place
sudo cp bsd /bsd

# extract relevant tarballs to root of drive, preserving permissions
for i in $EXTRACT_TARBALLS;
	do 
	echo -n "Untarring $i ... "
	sudo tar xzpf $i -C /;
	echo "done."
done

# extract etcXY.tgz and blindly copy certain files into place
echo "Replacing unchanged files..."
if [ -f /etc/unchangedfiles ]; then
	#sudo tar xzpf etc*.tgz -C $etctemp
	cd $etctemp

	while read unchanged; do
		echo cp $unchanged /
	done < /etc/unchangedfiles
fi

cd ~
rm -rf $tempdl $etctemp
