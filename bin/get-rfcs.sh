#!/bin/sh
#
# RFCs are handy to have available offline; text-only of course and
# updated weekly.

rsync -avz --delete \
	--exclude \*.pdf \
	--exclude \*.xml \
	--exclude \*\% \
	--exclude \*\~ \
	--exclude *[0-9] \
	rsync.ietf.org::rfc/*.txt /var/rfc
