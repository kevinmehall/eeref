from common import CachedFile
import re

f = CachedFile('http://www.nxp.com/documents/user_manual/UM10503.pdf', 'nxp-lpc4300um.pdf')

lines = f.pdflayout(startpage=177, lastpage=225).splitlines()

new_signal_re = re.compile('^P\d+_\d+')
footer_re = re.compile('^UM\d+')

pinout = {}
signal = None
periph_signal = None
peripheral_signals = {}

package_cols = ['LBGA256', 'TFBGA180', 'TFBGA100', 'LQFP208', 'LQFP144']

for package in package_cols:
	pinout[package] = {'pins':{}}          

for line in lines:
	line = line.decode('utf8').ljust(120)

	new_signal_match =  new_signal_re.match(line)
	if new_signal_match:
		signal = new_signal_match.group(0)
		pins = line[17:72].split()

		#print 'signal', signal, zip(package_cols, pins)

		for package, pin in zip(package_cols, pins):
			pinout[package]['pins'][pin] = signal
	elif footer_re.match(line):
		signal = None

	if signal:
		tp = line[103:112].strip()
		descr = line[112:].strip()

		if u' \u2014 ' in descr:
			periph_signal, descr = descr.split(u' \u2014 ')
			peripheral_signals[periph_signal] = {'type':tp, 'signal':signal, 'description':descr}
		elif descr:
			peripheral_signals[periph_signal]['description'] += " "+descr

import pprint

pprint.pprint(pinout)
pprint.pprint(peripheral_signals)

# TODO: parse the debug, analog and power pins on subsequent pages