# pad-stdio [![Build Status](https://travis-ci.org/sindresorhus/pad-stdio.svg?branch=master)](https://travis-ci.org/sindresorhus/pad-stdio)

> Pad stdout and stderr

Especially useful with CLI tools when you don't directly control the output.

![](https://f.cloud.github.com/assets/170270/2420088/0c74e148-ab6a-11e3-9c1e-3ea2b91d24f2.png)


## Install

```sh
$ npm install --save pad-stdio
```


## Usage

```js
var padStdio = require('pad-stdio');

padStdio.stdout('  ');      // start padding
console.log('foo');
padStdio.stdout('    ');
console.log('bar');
padStdio.stdout();          // end padding
console.log('baz');

/*
  foo
    bar
baz
*/
```

## API

### padStdio.stdout(pad)

Pads each line of `process.stdout` with the supplied pad string until the method is called again with no arguments.

### padStdio.stderr(pad)

Pads each line of `process.stderr` with the supplied pad string until the method is called again with no arguments.


## License

MIT © [Sindre Sorhus](http://sindresorhus.com)
