#!/bin/sh
#
# Fetches and extracts subtitles from subscene.com
_url=$1
_localfile=$RANDOM

if [ X != X$_url ]; then
	ftp -o $_localfile "$_url" && 7z x $_localfile && rm $_localfile
fi
