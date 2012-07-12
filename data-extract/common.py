import urllib2
import shutil
import os
from subprocess import Popen, PIPE

CACHE_DIR = 'cache'

class CachedFile(object):
	def __init__(self, url, fname, download=True):
		self.url = url
		self.fname = fname
		if download and not os.path.exists(self.path):
			self.download()

	@property
	def path(self):
		return os.path.join(CACHE_DIR, self.fname)

	def download(self):
		if not os.path.isdir(CACHE_DIR):
			os.mkdir(CACHE_DIR)

		print "Downloading", self.fname, '...', 

		request = urllib2.urlopen(self.url)
		with open(self.path, 'wb') as f:
			shutil.copyfileobj(request, f)
		request.close()

		print 'done'

	def pdflayout(self, startpage=None, lastpage=None):
		args = []
		if startpage is not None:
			args += ['-f', str(startpage)]
		if lastpage is not None:
			args += ['-l', str(lastpage)]
		process = Popen(["pdftotext", "-layout"] + args + [self.path, '-'], stdout=PIPE)
		output = process.communicate()[0]
		process.wait()
		return output


