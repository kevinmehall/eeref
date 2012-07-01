w = 400
h = 400

chart = d3.select("body")
    .append("svg:svg")
    .attr("class", "chart")
    .attr("width", w)
    .attr("height", h)
    
zoom = 2
cx = w/2
cy = h/2
cs = Math.min(w, h)/zoom
rotate = 135

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
        .attr('r',  0.05)
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
