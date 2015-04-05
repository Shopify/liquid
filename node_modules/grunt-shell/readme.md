# grunt-shell [![Build Status](https://travis-ci.org/sindresorhus/grunt-shell.svg?branch=master)](https://travis-ci.org/sindresorhus/grunt-shell)

> Run shell commands

A good way to interact with other CLI tools. E.g. compiling Compass `compass compile` or get the current git branch `git branch`.

**Use [StackOverflow](http://stackoverflow.com/questions/tagged/gruntjs) for support questions.**


## Install

```sh
$ npm install --save-dev grunt-shell
```


## Usage

```js
require('load-grunt-tasks')(grunt); // npm install --save-dev load-grunt-tasks

grunt.initConfig({
	shell: {
		options: {
			stderr: false
		},
		target: {
			command: 'ls'
		}
	}
});

grunt.registerTask('default', ['shell']);
```


## Examples

### Run command

Create a folder named `test`.

```js
grunt.initConfig({
	shell: {
		makeDir: {
			command: 'mkdir test'
		}
	}
});
```

The `command` property supports templates:

```js
grunt.initConfig({
	testDir: 'test',
	shell: {
		makeDir: {
			command: 'mkdir <%= testDir %>'
		}
	}
});
```

You can also supply a function that returns the command:

```js
grunt.initConfig({
	shell: {
		hello: {
			command: function () {
				return 'echo hello';
			}
		}
	}
});
```

Which can also take arguments:

```js
module.exports = function(grunt) {
	grunt.loadNpmTasks('grunt-shell');
	grunt.initConfig({
		shell: {
			greet: {
				command: function (greeting) {
					return 'echo ' + greeting;
				}
			}
		}
	});
	grunt.registerTask('default', ['shell:greet:hello']);
}
```

### Run command and display the output

Output a directory listing in your Terminal.

```js
grunt.initConfig({
	shell: {
		dirListing: {
			command: 'ls'
		}
	}
});
```

### Custom callback

Do whatever you want with the output.

```js
function log(err, stdout, stderr, cb) {
	console.log(stdout);
	cb();
}

grunt.initConfig({
	shell: {
		dirListing: {
			command: 'ls',
			options: {
				callback: log
			}
		}
	}
});
```

### Option passed to the .exec() method

Run a command in another directory. In this example we run it in a subfolder using the `cwd` (current working directory) option.

```js
grunt.initConfig({
	shell: {
		subfolderLs: {
			command: 'ls',
			options: {
				stderr: false,
				execOptions: {
					cwd: 'tasks'
				}
			}
		}
	}
});
```

### Multiple commands

Run multiple commands by placing them in an array which is joined using `&&` or `;`. `&&` means run this only if the previous command succeeded. You can also use `&` to have the commands run concurrently (by executing all commands except the last one in a subshell).

```js
grunt.initConfig({
	shell: {
		multiple: {
			command: [
				'mkdir test',
				'cd test',
				'ls'
			].join('&&')
		}
	}
});
```


## Config

### command

*Required*  
Type: `string`, `function`

The command you want to run or a function which returns it. Supports underscore templates.

## Options

### stdout

Type: `boolean`  
Default: `true`

Show stdout in the Terminal.

### stderr

Type: `boolean`  
Default: `true`

Show stderr in the Terminal.

### stdin

Type: `boolean`  
Default: `true`

Forward the terminal's stdin to the command.

### failOnError

Type: `boolean`  
Default: `true`

Fail task if it encounters an error. Does not apply if you specify a `callback`.

### stdinRawMode

Type: `boolean`  
Default: `false`

This sets `stdin` to [act as a raw device](http://nodejs.org/api/tty.html#tty_rs_setrawmode_mode).

### callback(err, stdout, stderr, cb)

Type: `function`  
Default: `function () {}`

Lets you override the default callback with your own.

**Make sure to call the `cb` method when you're done.**

### execOptions

Type: `object`

Specify some options to be passed to the [.exec()](http://nodejs.org/api/child_process.html#child_process_child_process_exec_command_options_callback) method:

- `cwd` String *Current working directory of the child process*
- `env` Object *Environment key-value pairs*
- `setsid` Boolean
- `encoding` String *(Default: 'utf8')*
- `timeout` Number *(Default: 0)*
- `maxBuffer` Number *(Default: 200\*1024)*
- `killSignal` String *(Default: 'SIGTERM')*


## License

MIT © [Sindre Sorhus](http://sindresorhus.com)
