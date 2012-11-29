d3 = require('d3')()

module.exports = class TQFP
	constructor: (@pinCount, pitch) ->
		@svg = document.createElementNS(d3.ns.prefix.svg, 'svg')

		rotate = -45
		@s = d3.select(@svg)
				.attr('width', '100%')
				.attr('height', '100%')
				.attr('viewBox', '-1 -0.5 2 1')
				.attr('preserveAspectRatio', 'xMidYMid meet')
				.append("svg:g")
					.attr('transform', "
						  scale(#{0.8/Math.sqrt(2)})
					      translate(-0.5, -0.5)
					      rotate(#{rotate}, 0.5, 0.5)")

	draw: ->
		# the chip itself
		@s.append("svg:rect")
			.attr("x", 0)
			.attr("y", 0)
			.attr("width", 1)
			.attr("height", 1)
			.attr('fill', "#222222")

		# the pin 1 dot
		@s.append("svg:circle")
			.attr('cx', 0.1)
			.attr('cy', 0.1)
			.attr('r',  0.03)
			.attr('fill', 'rgba(255, 255, 255, 0.5)')

		position = d3.scale.ordinal()
			.domain([1..@pinCount/4])
			.rangeBands([0.03, 0.97], @pinCount/400)

		@pins = []
		for side in [0...4]
			for sidePin in [1..@pinCount/4]
				@pins.push @s.append("svg:rect")
					.attr('class', 'pin')
					.attr('fill', '#666666')
					.attr('width', position.rangeBand())
					.attr('height', 0.08)
					.attr('x', position(sidePin))
					.attr('y', -0.08)
					.attr('data-pin', @pinCount-@pins.length)
					.attr('transform', "rotate(#{side*90 }, 0.5, 0.5)")
					.node()

		self = this
		return -> this.appendChild(self.svg)