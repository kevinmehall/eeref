
viewSection = document.getElementById('view')
w = viewSection.clientWidth
h = viewSection.clientHeight

console.log(viewSection, w,h)

chart = d3.select(viewSection)
    .append("svg:svg")
		.attr("class", "chart")
		.attr("width", w)
		.attr("height", h)
		
zoom = 2
cx = w/2
cy = h/2
cs = Math.min(w, h)/zoom
rotate = -45

chip = chart.append("svg:g")
    .attr('transform', "rotate(#{rotate}, #{cx}, #{cy}) translate(#{cx}, #{cy}) scale(#{cs}) translate(-0.5, -0.5)")
    
    
chip.append("svg:rect")
        .attr("x", 0)
        .attr("y", 0)
        .attr("width", 1)
        .attr("height", 1)
        .attr('fill', "#222222")
        
pins = ({pin:i} for i in [1..100])
 
p = d3.scale.ordinal()
        .domain([1..25])
        .rangeBands([0.03, 0.97], 0.25)
    
dot = chip.append("svg:circle")
        .attr('cx', 0.1)
        .attr('cy', 0.1)
        .attr('r',  0.03)
        .attr('fill', 'rgba(255, 255, 255, 0.5)')
        
chip.selectAll('rect.pin')
        .data(pins)
        .enter().append("svg:rect")
             .attr('class', 'pin')
             .attr('data-pin', (d)->d.pin)
             .attr('fill', '#666666')
             .attr('width', p.rangeBand())
             .attr('height', 0.08)
             .attr('x', (d)->p((d.pin-1)%25+1))
             .attr('y', -0.08)
             .attr('transform', (d)->"rotate(#{Math.floor((d.pin-1)/25)*90}, 0.5, 0.5)")
             .on('mouseover', (d) ->
             	d3.select(this).classed('selected', true)
             	
             	angle = (Math.floor((d.pin-1)/25)*90 + rotate - 90)
             	xv = Math.cos(angle * (Math.PI / 180))
             	yv = Math.sin(angle * (Math.PI / 180))
             	
             	ttx = w/2 + xv*cs
             	tty = h/2 + yv*cs
             	
             	tooltip = d3.select(viewSection).append("div")
             		.attr('class', 'pin-tooltip')
             		.style('left', "#{ttx}px")
             		.style('top', "#{tty}px")
             		
             	tooltip.append('h1')
             		.text("Pin #{d.pin}")
             		
             	d.tooltip = tooltip	
             )
             .on('mouseout', (d) ->
             	d3.select(this).classed('selected', false)
             	
             	d.tooltip
             		.style('-webkit-animation', 'fadeOut 500ms ease 500ms')
             		.on('webkitAnimationEnd', -> d3.select(this).remove())
             	
             	delete d.tooltip
             )
