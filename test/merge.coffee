m = require '../obj'

describe 'split key', ->
	it 'passes through normal keys', ->
		m.split 'foo', {k:'foo', op:''}

	it 'splits =', ->
		m.split 'foo=', {k:'foo', op:''}

describe 'merge', ->
	simpleDoc = 
		data: {a:5}
		source: {a:'old'}

	it 'merges unique keys', ->
		eq m.merge(simpleDoc, {b:6}, 'new'),
			{data:{a:5, b:6}, source:{a:'old', b:'new'}}

	it "won't overwrite scalars", ->
		throws -> eq m.merge(simpleDoc, {a:9}, 'new')

	it "will overwrite scalars with = flag", ->
		eq m.merge(simpleDoc, {'a=':9}, 'new'),
			{data:{a:9}, source:{a:'new'}}

	it "ignores overwrites with ?", ->
		eq m.merge(simpleDoc, {'a?':9}, 'new'),
			{data:{a:5}, source:{a:'old'}}


	nestedDoc = 
		data: {n:{a:5}}
		source: {n:{a:'old'}}

	it 'merges recursively', ->
		eq m.merge(nestedDoc, {n:{b:10}}, 'new'),
			{data:{n:{a:5, b:10}}, source:{n:{a:'old',b:'new'}}}

	it 'overwrites entire subtrees with =', ->
		eq m.merge(nestedDoc, {'n=':{b:10}}, 'new'),
			{data:{n:{b:10}}, source:{n:{b:'new'}}}

	it 'ignores entire subtrees with ?', ->
		eq m.merge(nestedDoc, {'n?':{b:10}}, 'new'),
			{data:{n:{a:5}}, source:{n:{a:'old'}}}