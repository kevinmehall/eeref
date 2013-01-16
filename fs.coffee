fs = require 'fs'
path = require 'path'
readdirp = require 'readdirp'

# Wrap a filesystem directory in an interface that can also be built on top of
# a git db or browser localstorage. `/` becomes the base directory.

normalizePath = (p) ->
	p = path.normalize(p)
	if p[0] is '/'
		p = p.slice(1)
	if p.slice(2) is '..'
		throw new Error('bad path')
	return p


@FSDir = class FSDir
	constructor: (@base) ->

	path: (p) ->
		path.join(@base, normalizePath(p))

	read: (fname, cb) ->
		fs.readFile(@path(fname), 'utf8', cb)

	write: (fname, data, cb) ->
		fs.writeFile(@path(fname), data, 'utf8', cb)

	list: (fileFilter=[], cb) ->
		r = readdirp {root:@base, directoryFilter:['!.git'], fileFilter}
		data = []
		r.on 'data', (entry) ->
			data.push entry.path
		r.on 'error', (e) ->
			cb e, null
		r.on 'end', ->
			cb null, data

@FSMock = class FSMock
	constructor: (@data={}) ->

	read: (fname, cb) ->
		fname = normalizePath(fname)
		if fname of @data
			cb(false, @data[fname])
		else
			cb(new Error("#{fname} does not exist"))

	write: (fname, d, cb) ->
		@data[normalizePath(fname)] = d
		cb(false)

	list: (fileFilter=[], cb) ->
		cb null, Object.keys(@data)
