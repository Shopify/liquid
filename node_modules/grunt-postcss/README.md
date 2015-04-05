# grunt-postcss
[![Build Status](https://travis-ci.org/nDmitry/grunt-postcss.png?branch=master)](https://travis-ci.org/nDmitry/grunt-postcss)
[![Dependency Status](https://david-dm.org/nDmitry/grunt-postcss.png)](https://david-dm.org/nDmitry/grunt-postcss)

> Apply several post-processors to your CSS using [PostCSS](https://github.com/postcss/postcss).

## Getting Started
This plugin requires Grunt `~0.4.0`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```shell
npm install grunt-postcss --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```js
grunt.loadNpmTasks('grunt-postcss');
```

## Usage

```
$ npm install grunt-postcss autoprefixer-core csswring
```

```js
grunt.initConfig({
  postcss: {
    options: {
      map: true,
      processors: [
        require('autoprefixer-core')({browsers: 'last 1 version'}).postcss,
        require('csswring').postcss
      ]
    },
    dist: {
      src: 'css/*.css'
    }
  }
});
```

The usage and options are similar with [grunt-autoprefixer](https://github.com/nDmitry/grunt-autoprefixer#options) (except `browsers` option). The only new option is:

#### options.processors
Type: `Array`
Default value: `[]`

An array of PostCSS compatible post-processors.

## Why would I use this?

Unlike the traditional approach with separate plugins, grunt-postcss allows you to parse and save CSS only once applying all post-processors in memory and thus reducing your build time. PostCSS is also a simple tool for writing your own CSS post-processors.
