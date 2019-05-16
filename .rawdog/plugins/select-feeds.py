# Select feeds to include in rawdog's output.
# Copyright 2005, 2013 Adam Sampson <ats@offog.org>
#
# Usage in config file:
#   selectfeeds [feedurls]
# If selectfeeds is not given, all feeds will be included.

import rawdoglib.rawdog, rawdoglib.plugins

feeds = {}

def option(config, name, value):
	global feeds
	if name == "selectfeeds":
		for feed in rawdoglib.rawdog.parse_list(value):
			feeds[feed] = True
		return False
	else:
		return True
rawdoglib.plugins.attach_hook("config_option", option)

def filter(rawdog, config, articles):
	if len(feeds) != 0:
		articles[:] = [a for a in articles if feeds.has_key(a.feed)]
	return True
rawdoglib.plugins.attach_hook("output_sorted_filter", filter)

