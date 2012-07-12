import re
import pprint

info = map(lambda tlist: \
	map(lambda item: \
		item.ljust(max(map(len, tlist))), tlist), \
		map(lambda x: \
			x.splitlines(), open("tables").read().split('\n\n')))

pairify = lambda lst: zip(lst,lst[1::])

cutPoints = lambda lst: \
	[0] + map(lambda x: \
		x.span()[0], \
		re.finditer(" \w+ ?\w*\S* ", lst[0]))

split = lambda lst: \
	map(lambda x: \
		map(lambda y: \
			y[x[0]:x[1]].strip(), \
			lst), \
	pairify(cutPoints(lst))[1::])

pprint.pprint(map(split, info))
