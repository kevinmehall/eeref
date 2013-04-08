m = require '../obj'

describe 'split key', ->
	it 'passes through normal keys', ->
		m.split 'foo', {k:'foo', op:''}

	it 'splits =', ->
		m.split 'foo=', {k:'foo', op:''}

describe 'stack', ->
	simpleDoc = 
		data: {a:5}
		source: {a:'old'}

	it 'merges unique keys', ->
		eq m.stack(simpleDoc, {b:6}, 'new'),
			{data:{a:5, b:6}, source:{a:'old', b:'new'}}

	it "won't overwrite scalars", ->
		throws -> eq m.stack(simpleDoc, {a:9}, 'new')

	it "will overwrite scalars with = flag", ->
		eq m.stack(simpleDoc, {'a=':9}, 'new'),
			{data:{a:9}, source:{a:'new'}}

	it "ignores overwrites with ?", ->
		eq m.stack(simpleDoc, {'a?':9}, 'new'),
			{data:{a:5}, source:{a:'old'}}


	nestedDoc = 
		data: {n:{a:5}}
		source: {n:{a:'old'}}

	it 'merges recursively', ->
		eq m.stack(nestedDoc, {n:{b:10}}, 'new'),
			{data:{n:{a:5, b:10}}, source:{n:{a:'old',b:'new'}}}

	it 'overwrites entire subtrees with =', ->
		eq m.stack(nestedDoc, {'n=':{b:10}}, 'new'),
			{data:{n:{b:10}}, source:{n:{b:'new'}}}

	it 'ignores entire subtrees with ?', ->
		eq m.stack(nestedDoc, {'n?':{b:10}}, 'new'),
			{data:{n:{a:5}}, source:{n:{a:'old'}}}

describe 'merge', ->
	it 'merges unique keys', ->
		eq (m.merge [
				{data:{a:1}, source:{a:'a'}}
				{data:{b:2}, source:{b:'b'}}
				{data:{c:3}, source:{c:'c'}}
			]),
			{data:{a:1, b:2, c:3}, source:{a:'a', b:'b', c:'c'}}

	it 'errors on conflict', ->
		throws -> m.merge [{data:{a:1}, source:{a:'a'}}, {data:{a:2}, source:{a:'b'}}]

	it 'allows conflict when sources are identical', ->
		m.merge [{data:{a:1}, source:{a:'a'}}, {data:{a:1, b:2}, source:{a:'a', b:'b'}}]

	it 'merges recursively', ->
		eq (m.merge [
				{data: {n:{a:5}}, source: {n:{a:'a'}}}
				{data: {n:{b:7}}, source: {n:{b:'b'}}}
			]),
			{data:{n:{a:5, b:7}}, source:{n:{a:'a',b:'b'}}}

