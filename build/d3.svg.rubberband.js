(function() {
  var D3SVGRubberband, d3_rubberband, d3_trackCursor;

  d3_trackCursor = function(ctx) {
    var f, g, rect, sel, xr, xscale, xy, yr, yscale;

    sel = ctx.selection;
    xscale = ctx.xscale;
    yscale = ctx.yscale;
    f = ctx.callback;
    xr = xscale.range();
    yr = yscale.range();
    (g = sel.append("g").classed("track-cursor", true)).selectAll("rect").data([{}]).enter().append("rect").attr({
      fill: "transparent"
    }).attr({
      x: xr[0],
      width: xr[1] - xr[0],
      y: yr[1],
      height: yr[0] - yr[1]
    });
    rect = sel.selectAll("g.track-cursor rect");
    xy = function() {
      var d;

      d = d3.mouse(rect.node());
      return [xscale.invert(d[0]), yscale.invert(d[1])];
    };
    return rect.on("mouseover.track-cursor", function() {
      return f(xy(), "mouseover", g);
    }).on("mousemove.track-cursor", function() {
      return f(xy(), "mousemove", g);
    }).on("mouseout.track-cursor", function() {
      return f(xy(), "mouseout", g);
    });
  };

  d3_rubberband = function(d3sel, xs, ys, funcs) {
    return d3_trackCursor({
      selection: d3sel,
      xscale: xs,
      yscale: ys,
      callback: function(xy, type, g) {
        var endpoints, xr, yr;

        xr = xs.range();
        yr = ys.range();
        endpoints = {
          x1: function(e) {
            if (e === "x") {
              return funcs.x(xy);
            } else {
              return xr[0];
            }
          },
          y1: function(e) {
            if (e === "x") {
              return yr[0];
            } else {
              return funcs.y(xy);
            }
          },
          x2: function(e) {
            if (e === "x") {
              return funcs.x(xy);
            } else {
              return xr[1];
            }
          },
          y2: function(e) {
            if (e === "x") {
              return yr[1];
            } else {
              return funcs.y(xy);
            }
          }
        };
        switch (type) {
          case "mouseover":
            g.selectAll("line").data(["x", "y"]).enter().insert("line", ":first-child").attr({
              "class": function(e) {
                return e;
              }
            }).attr(endpoints);
            return typeof funcs.mouseover === "function" ? funcs.mouseover(xy, g) : void 0;
          case "mousemove":
            g.selectAll("line").attr(endpoints);
            return typeof funcs.mousemove === "function" ? funcs.mousemove(xy, g) : void 0;
          case "mouseout":
            g.selectAll("line").remove();
            return typeof funcs.mouseout === "function" ? funcs.mouseout(xy, g) : void 0;
        }
      }
    });
  };

  D3SVGRubberband = (function() {
    function D3SVGRubberband(_d3sel, _xScale, _yScale) {
      var _this = this;

      this._d3sel = _d3sel;
      this._xScale = _xScale;
      this._yScale = _yScale;
      this._x = function(xy) {
        return _this._xScale(xy[0]);
      };
      this._y = function(xy) {
        return _this._yScale(xy[1]);
      };
    }

    return D3SVGRubberband;

  })();

  D3SVGRubberband.prototype.data = function(f) {
    this._data = f;
    return this;
  };

  D3SVGRubberband.prototype.x = function(f) {
    this._x = f;
    return this;
  };

  D3SVGRubberband.prototype.y = function(f) {
    this._y = f;
    return this;
  };

  D3SVGRubberband.prototype.text = function(f) {
    var _this = this;

    return d3_rubberband(this._d3sel, this._xScale, this._yScale, {
      x: this._x,
      y: this._y,
      mouseover: function(xy, g) {
        return g.append("g").classed("summary", true).attr({
          transform: "translate(-2, -4)"
        }).selectAll("text").data([_this._data(xy)]).enter().append("text").style("text-anchor", "end").text(f);
      },
      mousemove: function(xy, g) {
        return g.selectAll("text").attr({
          x: _this._x(xy),
          y: _this._y(xy)
        }).data([_this._data(xy)]).text(f);
      },
      mouseout: function(xy, g) {
        return g.selectAll("g.summary").remove();
      }
    });
  };

  d3.svg.rubberband = function(d3sel, xs, ys) {
    return new D3SVGRubberband(d3sel, xs, ys);
  };

}).call(this);
