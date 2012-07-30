import re
import pprint
import itertools

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

table = map(split, info)

heirarchical = map(lambda lst: \
	dict( \
		map(lambda lst: \
			(lst[0], lst[1::]), \
		lst) ), \
	table)

ports = map(lambda lst2: \
	map(lambda lst: \
		dict(zip(lst2.keys(), lst)), \
	zip(*lst2.values())), \
	heirarchical)

_flatten = lambda lst: \
	list( \
		itertools.chain( \
			*[[item] if type(item) not in [list, dict] else item for item in lst]))

pins = _flatten(ports)

pprint.pprint(pins)
