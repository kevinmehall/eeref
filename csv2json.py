import csv
import json

pincsv = csv.DictReader(open('pins.csv'), ['pin', 'type', 'signal'])

pins = [{'pin': int(i['pin']), 'signal':i['signal'], 'type':i['type']} for i in list(pincsv)[1:] if i['pin']]

pinsignals = set(i['signal'] for i in pins)
seensignals = set()

peripherals = {}

signalcsv = csv.DictReader(open('signals.csv'), ['signal', 'name', 'alternate', 'peripheral', 'direction'])

for i in signalcsv:
	if i['signal'] not in pinsignals or i['name'] in seensignals:
		# remove duplicates and signals that don't have a pin mapping
		continue
		
	seensignals.add(i['name'])

	p = i['peripheral']
	if p not in peripherals:
		peripherals[p] = {'signals':[], 'name':p}
	peripherals[p]['signals'].append(i)

o = {
	'package': 'qfp',
	'n_pins': 100,
	'pins': pins,
	'peripherals': sorted(peripherals.values(), key=lambda x: x['name']),
	'name': 'sam3u',
}

j = json.dumps(o, indent=4)
out = open("sam3u-lqfp100.json", 'w')
out.write(j)
out.close()


