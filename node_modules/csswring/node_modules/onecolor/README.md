one.color
=========

JavaScript color calculation toolkit for node.js and the browser.

Features:
* RGB, HSV, HSL, and CMYK colorspace support (experimental implementations of LAB and XYZ)
* Legal values for all channels are 0..1
* Instances are immutable -- a new object is created for each manipulation
* All internal calculations are done using floating point, so very little precision is lost due to rounding errors when converting between colorspaces
* Alpha channel support
* Extensible architecture -- implement your own colorspaces easily
* Chainable color manipulation
* Seamless conversion between colorspaces
* Outputs as hex, `rgb(...)`, `rgba(...)` or `hsv(...)`

Module support:
* CommonJS / Node
* AMD / RequireJS
* jQuery (installs itself on $.color)
* Vanilla JS (installs itself on one.color)

Package managers:
* npm: `npm install onecolor`
* bower: `bower install color`

WARNING IE USERS:
This library uses some modern ecmascript methods that aren't available in IE versions below IE9.
To keep the core library small, these methods aren't polyfilled in the library itself.
If you want IE support for older IE versions, please include <a href="//raw.github.com/One-com/one-color/master/one-color-ieshim.js">one-color-ieshim.js</a> before the color library. This is only needed if you don't already have a library installed that polyfills `Array.prototype.map`and `Array.prototype.forEach`.

Usage
-----

In the browser (change <a href="//raw.github.com/One-com/one-color/master/one-color.js">one-color.js</a> to <a href="//raw.github.com/One-com/one-color/master/one-color-all.js">one-color-all.js</a> to gain
named color support):

```html
<script src='one-color.js'></script>
<script>
    alert('Hello, ' + one.color('#650042').lightness(.3).green(.4).hex() + ' world!');
</script>
```

In node.js (after `npm install onecolor`):

```javascript
var color = require('onecolor');
console.warn(color('rgba(100%, 0%, 0%, .5)').alpha(.4).cssa()); // 'rgba(255,0,0,0.4)'
```

`one.color` is the parser. All of the above return color instances in
the relevant color space with the channel values (0..1) as instance
variables:

```javascript
var myColor = one.color('#a9d91d');
myColor instanceof one.color.RGB; // true
myColor.red() // 0.6627450980392157
```

You can also parse named CSS colors (works out of the box in node.js,
but the requires the slightly bigger <a href="//raw.github.com/One-com/one-color/master/one-color-all.js">one-color-all.js</a> build in the
browser):

```javascript
one.color('maroon').lightness(.3).hex() // '#990000'
```

To turn a color instance back into a string, use the `hex()`, `css()`,
and `cssa()` methods:

```javascript
one.color('rgb(124, 96, 200)').hex() // '#7c60c8'
one.color('#bb7b81').cssa() // 'rgba(187,123,129,1)'
```

Color instances have getters/setters for all channels in all supported
colorspaces (`red()`, `green()`, `blue()`, `hue()`, `saturation()`, `lightness()`,
`value()`, `alpha()`, etc.). Thus you don't need to think about which colorspace
you're in. All the necessary conversions happen automatically:

```javascript
one.color('#ff0000') // Red in RGB
    .green(1) // Set green to the max value, producing yellow (still RGB)
    .hue(.5, true) // Add 180 degrees to the hue, implicitly converting to HSV
    .hex() // Dump as RGB hex syntax: '#2222ff'
```

When called without any arguments, they return the current value of
the channel (0..1):

```javascript
one.color('#09ffdd').green() // 1
one.color('#09ffdd').saturation() // 0.9647058823529412
```

When called with a single numerical argument (0..1), a new color
object is returned with that channel replaced:

```javascript
var myColor = one.color('#00ddff');
myColor.red(.5).red() // .5

// ... but as the objects are immutable, the original object retains its value:
myColor.red() // 0
```

When called with a single numerical argument (0..1) and `true` as
the second argument, a new value is returned with that channel
adjusted:

```javascript
one.color('#ff0000') // Red
    .red(-.1, true) // Adjust red channel by -0.1
    .hex() // '#e60000'
```

Alpha channel
-------------

All color instances have an alpha channel (0..1), defaulting to 1
(opaque). You can simply ignore it if you don't need it.

It's preserved when converting between colorspaces:

```javascript
one.color('rgba(10, 20, 30, .8)')
    .green(.4)
    .saturation(.2)
    .alpha() // 0.8
```

Comparing color objects
-----------------------

If you need to know whether two colors represent the same 8 bit color, regardless
of colorspace, compare their `hex()` values:

```javascript
one.color('#f00').hex() === one.color('#e00').red(1).hex() // true
```

Use the `equals` method to compare two color instances within a certain
epsilon (defaults to `1e-9`).

```javascript
one.color('#e00').lightness(.00001, true).equals(one.color('#e00'), 1e-5) // false
one.color('#e00').lightness(.000001, true).equals(one.color('#e00'), 1e-5) // true
```

Before comparing the `equals` method converts the other color to the right colorspace,
so you don't need to convert explicitly in this case either:

```javascript
one.color('#e00').hsv().equals(one.color('#e00')) // true
```

API overview
============

Color parser function, the recommended way to create a color instance:

```javascript
one.color('#a9d91d') // Regular hex syntax
one.color('a9d91d') // hex syntax, # is optional
one.color('#eee') // Short hex syntax
one.color('rgb(124, 96, 200)') // CSS rgb syntax
one.color('rgb(99%, 40%, 0%)') // CSS rgb syntax with percentages
one.color('rgba(124, 96, 200, .4)') // CSS rgba syntax
one.color('hsl(120, 75%, 75%)') // CSS hsl syntax
one.color('hsla(120, 75%, 75%, .1)') // CSS hsla syntax
one.color('hsv(220, 47%, 12%)') // CSS hsv syntax (non-standard)
one.color('hsva(120, 75%, 75%, 0)') // CSS hsva syntax (non-standard)
one.color([0, 4, 255, 120]) // CanvasPixelArray entry, RGBA
one.color(["RGB", .5, .1, .6, .9]) // The output format of color.toJSON()
```

The slightly bigger <a href="//raw.github.com/One-com/one-color/master/one-color-all.js">one-color-all.js</a> build adds support for
<a href='http://en.wikipedia.org/wiki/Web_colors'>the standard suite of named CSS colors</a>:

```javascript
one.color('maroon')
one.color('darkolivegreen')
```

Existing one.color instances pass through unchanged, which is useful
in APIs where you want to accept either a string or a color instance:

```javascript
one.color(one.color('#fff')) // Same as one.color('#fff')
```

Serialization methods:

```javascript
color.hex() // 6-digit hex string: '#bda65b'
color.css() // CSS rgb syntax: 'rgb(10,128,220)'
color.cssa() // CSS rgba syntax: 'rgba(10,128,220,0.8)'
color.toString() // For debugging: '[one.color.RGB: Red=0.3 Green=0.8 Blue=0 Alpha=1]'
color.toJSON() // ["RGB"|"HSV"|"HSL", <number>, <number>, <number>, <number>]
```

Getters -- return the value of the channel (converts to other colorspaces as needed):

```javascript
color.red()
color.green()
color.blue()
color.hue()
color.saturation()
color.value()
color.lightness()
color.alpha()
color.cyan()    // one-color-all.js and node.js only
color.magenta() // one-color-all.js and node.js only
color.yellow()  // one-color-all.js and node.js only
color.black()   // one-color-all.js and node.js only
```

Setters -- return new color instances with one channel changed:

```javascript
color.red(<number>)
color.green(<number>)
color.blue(<number>)
color.hue(<number>)
color.saturation(<number>)
color.value(<number>)
color.lightness(<number>)
color.alpha(<number>)
color.cyan(<number>)    // one-color-all.js and node.js only
color.magenta(<number>) // one-color-all.js and node.js only
color.yellow(<number>)  // one-color-all.js and node.js only
color.black(<number>)   // one-color-all.js and node.js only
```

Adjusters -- return new color instances with the channel adjusted by
the specified delta (0..1):

```javascript
color.red(<number>, true)
color.green(<number>, true)
color.blue(<number>, true)
color.hue(<number>, true)
color.saturation(<number>, true)
color.value(<number>, true)
color.lightness(<number>, true)
color.alpha(<number>, true)
color.cyan(<number>, true)    // one-color-all.js and node.js only
color.magenta(<number>, true) // one-color-all.js and node.js only
color.yellow(<number>, true)  // one-color-all.js and node.js only
color.black(<number>, true)   // one-color-all.js and node.js only
```
Comparison with other color objects, returns `true` or `false` (epsilon defaults to `1e-9`):

```javascript
color.equals(otherColor[, <epsilon>])
```

Mostly for internal (and plugin) use:
-------------------------------------

"Low level" constructors, accept 3 or 4 numerical arguments (0..1):

```javascript
new one.color.RGB(<red>, <green>, <blue>[, <alpha>])
new one.color.HSL(<hue>, <saturation>, <lightness>[, <alpha>])
new one.color.HSV(<hue>, <saturation>, <value>[, <alpha>])
```
The <a href="//raw.github.com/One-com/one-color/master/one-color-all.js">one-color-all.js</a> build includes CMYK support:

```javascript
new one.color.CMYK(<cyan>, <magenta>, <yellow>, <black>[, <alpha>])
```

All color instances have `rgb()`, `hsv()`, and `hsl()` methods for
explicitly converting to another color space. Like the setter and
adjuster methods they return a new color object representing the same
color in another color space.

If for some reason you need to get all the channel values in a
specific colorspace, do an explicit conversion first to cut down on
the number of implicit conversions:

```javascript
var myColor = one.color('#0620ff').lightness(+.3).rgb();
// Alerts '0 0.06265060240963878 0.5999999999999999':
alert(myColor.red() + ' ' + myColor.green() + ' ' + myColor.blue());
```

Building
========

```
git clone https://github.com/One-com/one-color.git
cd one-color
npm install
make
```

If you aren't up for a complete installation, there are pre-built
packages in the repository as well as the npm package:

* Basic library: <a href="//raw.github.com/One-com/one-color/master/one-color.js">one-color.js</a>,
  debuggable version: <a href="//raw.github.com/One-com/one-color/master/one-color-debug.js">one-color-debug.js</a>
* Full library including named color support: <a href="//raw.github.com/One-com/one-color/master/one-color-all.js">one-color-all.js</a>,
  debuggable version: <a href="//raw.github.com/One-com/one-color/master/one-color-all-debug.js">one-color-all-debug.js</a>.

License
=======

one.color is licensed under a standard 2-clause BSD license -- see the LICENSE-file for details.
