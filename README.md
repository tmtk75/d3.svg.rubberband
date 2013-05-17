# README for d3.svg.rubberband

This is a [d3](http://d3js.org/) plugin which gives rubberbands to your linecharts.  
It's like a [d3.brush](https://github.com/mbostock/d3/wiki/SVG-Controls) in the control section of API Reference.

<svg width='100' height='50'>
  <line x1='0' y1='0' x2='100' y2='50' color='black' stroke='black'/>
</svg>

<div style='color:red'>colored style</div>

Here is a screenshot  
<img src='https://s3-ap-northeast-1.amazonaws.com/tmtk75.github.com/d3.svg.rubberband/overview.png'>

You will see a demo here,
<http://tmtk75.github.io/d3.svg.rubberband/>.

This demo is giving rubberband guide to a basic example of d3,
<http://bl.ocks.org/mbostock/3883245>.

# Usage
Load two files which are .js and .css.

```html
<link href="http://tmtk75.github.io/d3.svg.rubberband/build/d3.svg.rubberband.min.css" rel="stylesheet">
<script src="http://tmtk75.github.io/d3.svg.rubberband/build/d3.svg.rubberband.min.js"></script>
```

To use rubberband, you need three functions to provide what you want to show.

Here is the [a part of script](https://github.com/tmtk75/d3.svg.rubberband/blob/master/index.html#L88) in the demo page.

```coffeescript
d = (xy)-> data[(d3.bisector (e)-> e.date).left data, xy[0]]
t = (e)-> d3.time.format("#{e.close} at %b %-d") e.date
d3.svg.rubberband(svg, x, y)
      .data(d)
      .y((xy)-> y d(xy)?.close)
      .text(t)
```

`d3.svg.rubberband()` is constructor which needs a d3selection, x-scale and y-scale.
In this case, x-scale is `d3.time.scale` and x-scale is `d3.scale.linear`.

`.data()` requires a funciton to return the value corresponding to the point of cursor.
`xy` is an array which is [x, y]. In this case, returns an Object like {date, close}.

`.y()` requires a funciton to return y-value for given `xy`.
If not specified, `xy[0]` is used.

`.text()` requires a funciton to return a string corresponding to a value which
is passed from the function given to `data()`.
In this case, for example, returns `205.93 at Jan 18`.

# Excuse
This is just only tested for a linechart like the demo.

x-axis should be `d3.time.scale`, and y-axis should `d3.scale.linear`
if you use this as is.

# License
MIT License
