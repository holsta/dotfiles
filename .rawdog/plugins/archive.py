# rawdog plugin to write received articles out as Atom files
# Copyright 2005, 2009, 2013 Adam Sampson <ats@offog.org>

# This needs my atomwriter.py module, which is available from:
#   http://offog.org/code/misccode.html

import rawdoglib.plugins
import atomwriter
import os, time, errno, traceback
from pprint import pprint

class ArchiverException(Exception): pass

class Archiver:
	def __init__(self):
		self.articles = {}
		self.feeds = {}
		self.dir = os.getenv("HOME") + "/archive/feeds"
		self.now = 0

	def article_added(self, rawdog, config, article, now):
		feed = rawdog.feeds[article.feed]
		feed_id = feed.get_id(config)
		self.feeds[feed_id] = feed.feed_info

		l = self.articles.setdefault(feed_id, [])
		l.append(article.entry_info)

		self.now = now

		return True

	def shutdown(self, rawdog, config):
		day = time.strftime("%Y-%m-%d", time.localtime(self.now))

		for id, feed_info in self.feeds.items():
			entries = self.articles[id]
			if id == "":
				id = "unknown"
			if len(id) > 50:
				id = id[:50]
			config.log("Archiving ", len(entries), " articles for ", id)

			dn = self.dir + "/" + id
			try:
				os.makedirs(dn)
			except OSError:
				pass

			seq = 0
			while 1:
				fn = "%s/%s-%s-%d.atom" % (dn, id, day, seq)
				try:
					fd = os.open(fn, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
				except OSError, (no, s):
					if no == errno.EEXIST:
						seq += 1
						continue
					else:
						raise ArchiverException("Error opening " + fn + ": " + s)
				break

			atom_data = {"feed": feed_info, "entries": entries}

			f = os.fdopen(fd, "w")
			try:
				atomwriter.write_atom(atom_data, f)
			except:
				print "Error archiving article:"
				traceback.print_exc()
				pprint(atom_data)
			f.close()

		return True

archiver = Archiver()
rawdoglib.plugins.attach_hook("article_added", archiver.article_added)
rawdoglib.plugins.attach_hook("shutdown", archiver.shutdown)

