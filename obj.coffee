#async = require 'async'
path = require 'path'

# Split the operation off of a key name
@split = split = (k) ->
	if (op = k.slice(-1)) in [':', '=', '+', '?']
		{k:k.slice(0, -1), op}
	else
		{k, op:''}

nullDoc = {data:{}, source:{}}

# Merge two objects using rules based on gyp's config file format
# http://code.google.com/p/gyp/wiki/InputFormatReference#Merge_Basics_(=,_?,_+)
#
# Keys are suffixed with:
#   ":" the definition won't be inherited (not used in gyp)
#   "=" overwrite instead of merging
#   "+" append to beginning of list
#   "?" only if not already present
#
@merge = merge = ({data:a, source:aSrc}, b, thisSrc) ->
	o = {}
	s = {}

	for k, v of a
		unless aSrc[k] is ':'
			o[k] = v 
			s[k] = aSrc[k]
	
	for key, v of b
		{k, op} = split(key)
		if k not of o or op is '='
			if v instanceof Object and v not instanceof Array
				# Including a whole object, but we need to strip its tags and make a sources object
				{data:o[k], source:s[k]} = merge(nullDoc, v, thisSrc)
			else
				o[k] = v
				s[k] = thisSrc

		else if op is '?'
			continue

		else if o[k] instanceof Array
			unless v instanceof Array
				throw new Error "Can't merge array with non-array for property #{k}"
			if op is '+'
				o[k] = v.concat(o[k])
			else
				o[k] = o[k].concat(v)
			s[k] = thisSrc

		else if o[k] instanceof Object
			unless v instanceof Object and v not instanceof Array
				throw new Error "Can't merge dictionary with non-dictionary for property #{k}"
			{data:o[k], source:s[k]} = merge({data:a[k], source:aSrc[k]}, v, thisSrc)

		else
			throw new Error "Duplicate scalar without '=' to overwrite or '?' to ignore (property #{k})"

		if op is ':'
			s[k] = ':'

	return {data:o, source:s}

@DataObj = class DataObj
	@get = (dir, path) ->
		dir.cache ?= {}
		dir.cache[path] ?= new DataObj(dir, path)

	# Private constructor: use DataObj.get
	constructor: (@dir, @path) ->
		@data = null
		@source = null
		@loaded = @dirty = @error = false

	fetch: (cb) ->
		if @loaded or @error
			cb(@error, this)
		else
			@_load(cb)
		return this

	_load: (cb) ->
		@dir.read @path, (e, s) =>
			if e then return cb(@error = e)

			@raw = JSON.parse(s)
			@deps = for p in (@raw.includes or [])
				DataObj.get(@dir, path.join(@path, '..', p))

			#async.forEach @deps, ((x, cb)->x.fetch(cb)), (err) ->

			withData = (dep) =>
				{@data, @source} = merge(dep, @raw, this)
				@loaded = true
				cb(false, this)

			if @deps.length == 0
				withData(nullDoc)
			else if @deps.length == 1
				@deps[0].fetch (error, dep) =>
					if error
						@error = true 
						return cb(error)
					withData(dep)
			else
				cb(new Error 'Only one include allowed for now')

		return this

	get: (path) ->
		data = @data
		source = @source
		for i in path
			return undefined unless data and source
			data = data[i]
			source = source[i]
		return {data, source}

