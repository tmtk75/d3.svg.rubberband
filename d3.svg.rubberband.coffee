# given arguments
# callback:
#   xy: array [x, y]
#     x: value on x-scale corresponding to cursor-x
#     y: value on y-scale corresponding to cursor-y
#   type: string "mouseover" | "mousemove" | "mouseout"
#   g: svg group element which is parent node of rect raised events
d3_trackCursor = (ctx)->
  sel = ctx.selection
  xscale = ctx.xscale
  yscale = ctx.yscale
  f = ctx.callback
  xr = xscale.range()
  yr = yscale.range()
  (g = sel.append("g")
           .classed("track-cursor", true))
     .selectAll("rect")
     .data([{}])
     .enter()
     .append("rect")
     .attr(fill:"transparent")
     .attr(x:xr[0], width:xr[1]-xr[0], y:yr[1], height:yr[0]-yr[1])
  rect = sel.selectAll("g.track-cursor rect")
  xy = ->
    d = d3.mouse rect.node()
    [xscale.invert(d[0]), yscale.invert(d[1])]
  rect.on("mouseover.track-cursor", -> f xy(), "mouseover", g)
      .on("mousemove.track-cursor", -> f xy(), "mousemove", g)
      .on("mouseout.track-cursor",  -> f xy(), "mouseout",  g)

d3_rubberband = (d3sel, xs, ys, funcs)->
  d3_trackCursor selection:d3sel, xscale:xs, yscale:ys, callback:(xy, type, g)->
    xr = xs.range()
    yr = ys.range()
    endpoints =
      x1:(e)-> if e is "x" then funcs.x xy else xr[0]
      y1:(e)-> if e is "x" then yr[0]      else funcs.y xy
      x2:(e)-> if e is "x" then funcs.x xy else xr[1]
      y2:(e)-> if e is "x" then yr[1]      else funcs.y xy
    switch type
      when "mouseover"
        g.selectAll("line").data(["x", "y"]).enter().insert("line", ":first-child")
         .attr(class:(e)-> e)
         .attr endpoints
        funcs.mouseover? xy, g
      when "mousemove"
        g.selectAll("line")
         .attr endpoints
        funcs.mousemove? xy, g
      when "mouseout"
        g.selectAll("line").remove()
        funcs.mouseout? xy, g

class D3SVGRubberband
  constructor: (@_d3sel, @_xScale, @_yScale)->
    @_x = (xy)=> @_xScale xy[0]
    @_y = (xy)=> @_yScale xy[1]

D3SVGRubberband::data = (f)-> @_data = f; this

D3SVGRubberband::x = (f)-> @_x = f; this

D3SVGRubberband::y = (f)-> @_y = f; this

D3SVGRubberband::text = (f)->
  d3_rubberband @_d3sel, @_xScale, @_yScale,
    x: @_x
    y: @_y
    mouseover: (xy, g)=>
      g.append("g").classed("summary", true)
       .attr(transform:"translate(-2, -4)")
       .selectAll("text")
       .data([@_data xy]).enter().append("text")
       .style("text-anchor", "end") # start | middle | end
       .text(f)
    mousemove: (xy, g)=>
      g.selectAll("text")
       .attr(x:(@_x xy), y:(@_y xy))
       .data([@_data xy])
       .text(f)
    mouseout: (xy, g)=>
      g.selectAll("g.summary").remove()

d3.svg.rubberband = (d3sel, xs, ys)-> new D3SVGRubberband d3sel, xs, ys
