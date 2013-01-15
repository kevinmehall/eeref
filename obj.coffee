async = require 'async'
path = require 'path'

# Split the operation off of a key name
@split = split = (k) ->
	if (op = k.slice(-1)) in [':', '=', '+', '?']
		{k:k.slice(0, -1), op}
	else
		{k, op:''}

# Is a dictionary-like object (not an array)
@isDict = isDict = (v) -> v.constructor is Object

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
@stack = stack = ({data:a, source:aSrc}, b, thisSrc) ->
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
				{data:o[k], source:s[k]} = stack(nullDoc, v, thisSrc)
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
			unless isDict(v)
				throw new Error "Can't merge dictionary with non-dictionary for property #{k}"
			{data:o[k], source:s[k]} = stack({data:a[k], source:aSrc[k]}, v, thisSrc)

		else
			throw new Error "Duplicate scalar without '=' to overwrite or '?' to ignore (property #{k})"

		if op is ':'
			s[k] = ':'

	return {data:o, source:s}

@merge = merge = (objs) ->
	o = {}
	s = {}

	for {data:a, source:aSrc} in objs
		for key, v of a
			if key not of o
				o[key] = v
				s[key] = aSrc[key]
			else if isDict(o[key]) and isDict(v)
				{data:o[key], source:s[key]} = merge [
					{data:o[key], source:s[key]}
					{data:v,      source:aSrc[key]}
				]
			else if s[key] is aSrc[key]
				# do nothing, keep existing value
			else
				throw new Error "Can't merge `#{key}:` #{o[key]} and #{v}"

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
		@dir.read @path, (err, s) =>
			if err then return cb(@error = err)

			@raw = JSON.parse(s)
			@deps = for p in (@raw.includes or [])
				DataObj.get(@dir, path.join(@path, '..', p))

			async.forEach @deps, ((x, cb)->x.fetch(cb)), (err) =>
				if err then return cb(@error=err)

				{@data, @source} = stack(merge(@deps), @raw, this)
				@loaded = true
				cb(false, this)

		return this

	get: (path) ->
		data = @data
		source = @source
		for i in path
			return undefined unless data and source
			data = data[i]
			source = source[i]
		return {data, source}
