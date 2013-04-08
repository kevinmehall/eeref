import json
import sys
import os
from collections import OrderedDict

# variants = {
# 	"-AU": "TQFP44",
# 	"-MH": "QFN44",
# 	"-CU": "BGA49",
# }

variants = {
	"-AU": "100A",
	"-CU": "100C1",
	"-C7U": "100C2"
}

d = sys.argv[1]

for i in sys.argv[2:]:
	if not os.path.exists(os.path.join(d, i+'.json')):
		print i, "does not exist"
		continue

	for variant, package in variants.iteritems():
		name = "ATXMEGA" + i.upper() + variant
		fname = os.path.join(d, name + ".json")
		j = OrderedDict()
		j["includes"] = [i+".json"]
		j["schema="] = "part"
		j["name="] = name
		j["package"] = package

		open(fname, 'w').write(json.dumps(j, indent=4))
		