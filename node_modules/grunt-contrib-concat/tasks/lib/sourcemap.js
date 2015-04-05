/*
 * grunt-contrib-concat
 * http://gruntjs.com/
 *
 * Copyright (c) 2015 "Cowboy" Ben Alman, contributors
 * Licensed under the MIT license.
 */

'use strict';

exports.init = function(grunt) {
  var exports = {};

  // Node first party libs
  var path = require('path');

  // Third party libs
  var chalk = require('chalk');
  var SourceMapConsumer = require('source-map').SourceMapConsumer;
  var SourceMapGenerator = require('source-map').SourceMapGenerator;
  var SourceNode = require('source-map').SourceNode;

  // Return an object that is used to track sourcemap data between calls.
  exports.helper = function(files, options) {
    // Figure out the source map destination.
    var dest = files.dest;
    if (options.sourceMapStyle === 'inline') {
      // Leave dest as is. It will be used to compute relative sources.
    } else if (typeof options.sourceMapName === 'string') {
      dest = options.sourceMapName;
    } else if (typeof options.sourceMapName === 'function') {
      dest = options.sourceMapName(dest);
    } else {
      dest = dest + '.map';
    }

    // Inline style and sourceMapName together doesn't work
    if (options.sourceMapStyle === 'inline' && options.sourceMapName) {
      grunt.log.warn(
        'Source map will be inlined, sourceMapName option ignored.'
      );
    }

    return new SourceMapConcatHelper({
      files: files,
      dest: dest,
      options: options
    });
  };

  function SourceMapConcatHelper(options) {
    this.files = options.files;
    this.dest = options.dest;
    this.options = options.options;

    // Create the source map node we'll add concat files into.
    this.node = new SourceNode();

    // Create an array to store source maps that are referenced from files
    // being concatenated.
    this.maps = [];
  }

  // Construct a node split by a zero-length regex.
  SourceMapConcatHelper.prototype._dummyNode = function(src, name) {
    var node = new SourceNode();
    var lineIndex = 1;
    var charIndex = 0;
    // Tokenize on words, new lines, and white space.
    var tokens = src.split(/(\n|[^\S\n]+|\b)/g);
    // Filter out empty strings.
    tokens = tokens.filter(function(t) { return !!t; });

    tokens.forEach(function(token) {
      node.add(new SourceNode(lineIndex, charIndex, name, token));
      if (token === '\n') {
        lineIndex++;
        charIndex = 0;
      } else {
        charIndex += token.length;
      }
    });

    return node;
  };

  // Add some arbitraty text to the sourcemap.
  SourceMapConcatHelper.prototype.add = function(src) {
    // Use the dummy node to track new lines and character offset in the unnamed
    // concat pieces (banner, footer, separator).
    this.node.add(this._dummyNode(src));
  };

  // Add the lines of a given file to the sourcemap. If in the file, store a
  // prior sourcemap and return src with sourceMappingURL removed.
  SourceMapConcatHelper.prototype.addlines = function(src, filename) {
    var relativeFilename = path.relative(path.dirname(this.dest), filename);
    // sourceMap path references are URLs, so ensure forward slashes are used for paths passed to sourcemap library
    relativeFilename = relativeFilename.replace(/\\/g, '/');
    var node;
    if (
      /\/\/[@#]\s+sourceMappingURL=(.+)/.test(src) ||
        /\/\*#\s+sourceMappingURL=(\S+)\s+\*\//.test(src)
    ) {
      var sourceMapFile = RegExp.$1;
      var sourceMapPath;

      var sourceContent;
      // Browserify, as an example, stores a datauri at sourceMappingURL.
      if (/data:application\/json;base64,([^\s]+)/.test(sourceMapFile)) {
        // Set sourceMapPath to the file that the map is inlined.
        sourceMapPath = filename;
        sourceContent = new Buffer(RegExp.$1, 'base64').toString();
      } else {
        // If sourceMapPath is relative, expand relative to the file
        // refering to it.
        sourceMapPath = path.resolve(path.dirname(filename), sourceMapFile);
        sourceContent = grunt.file.read(sourceMapPath);
      }
      var sourceMap = JSON.parse(sourceContent);
      var sourceMapConsumer = new SourceMapConsumer(sourceMap);
      // Consider the relative path from source files to new sourcemap.
      var sourcePathToSourceMapPath =
        path.relative(path.dirname(this.dest), path.dirname(sourceMapPath));
      // sourceMap path references are URLs, so ensure forward slashes are used for paths passed to sourcemap library
      sourcePathToSourceMapPath = sourcePathToSourceMapPath.replace(/\\/g, '/');
      // Store the sourceMap so that it may later be consumed.
      this.maps.push([
        sourceMapConsumer, relativeFilename, sourcePathToSourceMapPath
      ]);
      // Remove the old sourceMappingURL.
      src = src.replace(/[@#]\s+sourceMappingURL=[^\s]+/, '');
      // Create a node from the source map for the file.
      node = SourceNode.fromStringWithSourceMap(
        src, sourceMapConsumer, sourcePathToSourceMapPath
      );
    } else {
      // Use a dummy node. Performs a rudimentary tokenization of the source.
      node = this._dummyNode(src, relativeFilename);
    }

    this.node.add(node);

    if (this.options.sourceMapStyle !== 'link') {
      this.node.setSourceContent(relativeFilename, src);
    }

    return src;
  };

  // Return the comment sourceMappingURL that must be appended to the
  // concatenated file.
  SourceMapConcatHelper.prototype.url = function() {
    // Create the map filepath. Either datauri or destination path.
    var mapfilepath;
    if (this.options.sourceMapStyle === 'inline') {
      var inlineMap = new Buffer(this._write()).toString('base64');
      mapfilepath = 'data:application/json;base64,' + inlineMap;
    } else {
      // Compute relative path to source map destination.
      mapfilepath = path.relative(path.dirname(this.files.dest), this.dest);
    }
    // Create the sourceMappingURL.
    var url;
    if (/\.css$/.test(this.files.dest)) {
      url = '\n/*# sourceMappingURL=' + mapfilepath + ' */';
    } else {
      url = '\n//# sourceMappingURL=' + mapfilepath;
    }

    return url;
  };

  // Return a string for inline use or write the source map to disk.
  SourceMapConcatHelper.prototype._write = function() {
    // ensure we're using forward slashes, because these are URLs
    var file = path.relative(path.dirname(this.dest), this.files.dest);
    file = file.replace(/\\/g, '/');
    var code_map = this.node.toStringWithSourceMap({
      file: file
    });
    // Consume the new sourcemap.
    var generator = SourceMapGenerator.fromSourceMap(
      new SourceMapConsumer(code_map.map.toJSON())
    );
    // Consume sourcemaps for source files.
    this.maps.forEach(Function.apply.bind(generator.applySourceMap, generator));
    // New sourcemap.
    var newSourceMap = generator.toJSON();
    // Return a string for inline use or write the map.
    if (this.options.sourceMapStyle === 'inline') {
      grunt.log.writeln(
        'Source map for ' + chalk.cyan(this.files.dest) + ' inlined.'
      );
      return JSON.stringify(newSourceMap, null, '');
    } else {
      grunt.file.write(
        this.dest,
        JSON.stringify(newSourceMap, null, '')
      );
      grunt.log.writeln('Source map ' + chalk.cyan(this.dest) + ' created.');
    }
  };

  // Non-private function to write the sourcemap. Shortcuts if writing a inline
  // style map.
  SourceMapConcatHelper.prototype.write = function() {
    if (this.options.sourceMapStyle !== 'inline') {
      this._write();
    }
  };

  return exports;
};
