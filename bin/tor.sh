#!/bin/sh

source ~/.profile
sshsock

cd ~/Downloads
for i in *.torrent; do
	[ "*.torrent" == "$i" ] && exit 1 ## no matches found, so exit now
	scp -- "$i" files.mongers.org:/famholst/new/.torrents && rm -- "$i"
done

