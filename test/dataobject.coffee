m = require '../obj'
{FSMock} = require '../fs'

describe 'DataObject', ->
	fs = new FSMock
		'file1.json': JSON.stringify {'name=':'file1', 'a?':5, b:10, opts:{x:45}}
		'file2.json': JSON.stringify {includes:['file1.json'], 'name=':'file2', c:9, opts:{y:99}}
	
	db = new m.DB fs
	
	it 'can be loaded', (d) ->
		db.get('file1.json').fetch (e, o) ->
			throw e if e
			eq o.data, {name:'file1', a:5, b:10, opts:{x:45}}
			d()

	it 'loads includes', (d) ->
		db.get('file2.json').fetch (e, o) ->
			throw e if e
			eq o.data, {name:'file2', a:5, b:10, opts:{x:45, y:99}, c:9}
			eq o.allIncludes(), ['file2.json', 'file1.json']
			d()

	it 'gets data by path', (d) ->
		db.get('file2.json').fetch (e, o) ->
			throw e if e
			r1 = o.get(['a'])
			eq r1.data, 5
			eq r1.source.path, 'file1.json'

			r2 = o.get(['opts', 'y'])
			eq r2.data, 99
			eq r2.source.path, 'file2.json'
			d()
