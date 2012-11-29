$ = require 'jquery'
d3 = (require 'd3')()

window.d3 = d3   

pkg =
	tqfp: require('./tqfp')

chart = null

$ ->
	chart = d3.select('#view')
		.append("svg:svg")
			.attr("class", "chart")
			.attr("width", '100%')
			.attr("height", '100%')
			
	d3.json "sam3u-lqfp100.json", (json) ->
		drawChip(json)
		
drawChip = (data) ->
	
	# Do some cross-linking that can't be represented in the JSON
	pinsBySignal = {}
	signalsByPin = {}
	for pin in data.pins
		pinsBySignal[pin.signal] = pin
		signalsByPin[pin.pin] = pin
		pin.functions = []
	
	for peripheral in data.peripherals
		for signal in peripheral.signals
			pin = pinsBySignal[signal.signal]
			if pin? then pin.functions.push(signal)

	chip = new pkg.tqfp(100)
	chart.select(chip.draw())

	pins = d3.selectAll(chip.pins)
		.datum(->signalsByPin[this.dataset.pin])
		.attr('fill', (d) -> 
			if d.type == 'PWR' then '#66aa88'
			else if not /P[AB]/.test(d.signal) then '#6688aa'
			else '#666666'
		)
		.on('mouseover', (d) -> pinSelect(d.signal, d.pin))
		.on('mouseout', -> pinDeselect())	

	tooltip = null
	
	pinSelect = (signal, pinno) ->
		rects = pins.filter((d) -> d.signal == signal)
		rects.classed('selected', true)

		return
		
		d = pinsBySignal[signal]
		pinno ?= d.pin
				 	
		angle = (Math.floor((pinno-1)/25)*90 + -45 - 90)
		xv = Math.cos(angle * (Math.PI / 180))
		yv = Math.sin(angle * (Math.PI / 180))

		ttx = w/2 + xv*cs
		tty = h/2 + yv*cs

		tooltip = d3.select(viewSection).append("div")
			.attr('class', 'pin-tooltip')
			.style('left', "#{ttx}px")
			.style('top', "#{tty}px")
	
		tooltip.append('h1')
			.text("Pin #{d.pin} - #{d.signal}")

		for fn in d.functions
			af = if fn.alternate then " (#{fn.alternate})" else ''
			tooltip.append('div').text(fn.name+af)
	

	pinDeselect = ->
		rects = pins.filter('.selected')
		rects.classed('selected', false)

		return
			
		if tooltip
			tooltip
				.style('-webkit-animation', 'fadeOut 300ms ease 100ms')
				.on('webkitAnimationEnd', -> d3.select(this).remove())

			tooltip = null

	signalsSelect = (signals) ->
		rects = pins.filter((d) -> d.signal in signals)
		rects.classed('selected', true)

	side = document.getElementById('side')
	peripheral_list = d3.select(side)
	
	console.log(side, peripheral_list)
	
	peripheral_div = peripheral_list.selectAll('div.peripheral')
		.data(data.peripherals)
		.enter().append('div')
			.attr('class', 'peripheral')
			
	peripheral_div.append('h1')
		.text((d) -> d.name)
		.on('mouseover', (d) ->
			signalsSelect(s.signal for s in d.signals)
		)
		.on('mouseout', pinDeselect)
		
	peripheral_div.selectAll('div.signal')
		.data((d) -> d.signals)
		.enter().append('div')
			.attr('class', 'signal')
			.text((d) -> d.name)
			.on('mouseover', (d) -> pinSelect(d.signal))
			.on('mouseout', pinDeselect)
			
