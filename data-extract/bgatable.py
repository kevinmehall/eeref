import sys
data = sys.stdin.read()

data = [[i.strip() for i in line.split('\t')] for line in data.split('\n')]

colhead = data[0][1:]
rowhead = [x[0] for x in data[1:]]
body = [x[1:] for x in data[1:]]

for row, l in zip(rowhead, body):
	for col, n in zip(colhead, l):
		print "%s%s: \"%s\""%(row, col, n)