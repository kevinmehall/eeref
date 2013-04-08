import sys
import re
from collections import OrderedDict
import json

data = sys.stdin.read()

blocks = data.split('\n\n\n')
peripherals = OrderedDict()
signals = set()
pins = []

def dictpath(d, path):
	if not path[0] in d:
		d[path[0]] = OrderedDict()
	if len(path) > 1:
		return dictpath(d[path[0]], path[1:])
	else:
		return d[path[0]]


for block in blocks:
	lines = [[i.strip() for i in line.split('\t')] for line in block.split('\n')]
	header = [re.sub("\(\d+\)| ", "", x) for x in lines[0][3:]]
	for line in lines[1:]:
		signal = line[0]
		signals.add(signal)

		if len(line) > 1:
			pins.append((line[1], signal))

		for p, s in zip(header, line[3:]):
			if not (signal and p and s): continue

			if p == 'EVENTOUT': p="EVSYS"
			if p in ['CLOCKOUT', 'TOSC', 'XTAL']: p="CLOCK"
			if p in ['REFA', 'REFB']:
				s=p
				p="AREF"

			flags = {}
			if '.' in p:
				[p, flag] = p.split('.')
				flags[flag] = True

			d = dictpath(peripherals, [p, 'signals', s])
			dictpath(d, ['pins'])[signal] = ""

			if flags:
				dictpath(d, ['flags']).update(flags)


for port in ['C', 'D', 'E', 'F']:
	#Pin mapping of all USART0 can optionally be moved to high nibble of port.
	# usart0 = peripherals.get('USART'+port+'0', None)
	# if usart0:
	# 	for i in 'XCK0', 'RXD0', 'TXD0':
	# 		lowpin = usart0['signals'][i]['pins'].keys()[0]
	# 		highpin = lowpin[:-1] + str(int(lowpin[-1])+4)
	# 		if highpin in signals:
	# 			print i, lowpin, highpin
	# 			usart0['signals'][i]['pins'][highpin] = "REMAP.USART0=1"

	# Pins MOSI and SCK for all SPI can optionally be swapped.
	spi = peripherals.get('SPI'+port, None)
	if spi:
		mosi = spi['signals']['MOSI']
		sck  = spi['signals']['SCK']
		mosipin = mosi['pins'].keys()[0]
		sckpin = sck['pins'].keys()[0]
		mosi['pins'][sckpin] = "REMAP.SPI=1"
		sck['pins'][mosipin] = "REMAP.SPI=1"

	evout = peripherals['EVSYS']['signals']['EVOUT']['pins']
	if 'P'+port+'7' in evout:
		evout['P'+port+'4'] = 'CLKEVPIN=1'

for k, v in peripherals.iteritems():
	if 'SPI' in k:
		v['protocols'] = {'spi':{'roles':{'master':True, 'slave':True}}}
	if 'USART' in k:
		v['protocols'] = {'async-serial':{'roles':{'tx':True, 'rx':True}}, 'spi':{'roles':{'master':True}}}
	if 'TWI' in k:
		v['protocols'] = {'i2c': {'roles':{'master':True, 'slave':True}}}
	if 'TC' in k[0:2]:
		v['protocols'] = {'pwm':{}}
	if 'PDI' in k:
		v['protocols'] = {'pdi':{}}

# peripherals['power'] = {
# 	"signals": {
# 		"VCC": {
# 			"type": "PWR",
# 			"pins":{
# 				"AVCC": "",
# 				"VCC": "",
# 				"VDD": ""
# 			}
# 		},
# 		"GND": {
# 			"type": "PWR",
# 			"pins":{
# 				"GND": ""
# 			}
# 		}
# 	}
# }

print json.dumps(OrderedDict(sorted(pins, key=lambda x: int(x[0]))), indent=4)

#print json.dumps(peripherals, indent=4)