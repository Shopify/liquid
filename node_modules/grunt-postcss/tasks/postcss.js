'use strict';

var path = require('path');
var postcss = require('postcss');
var diff = require('diff');
var chalk = require('chalk');

module.exports = function(grunt) {

    var options;
    var processor;

    /**
     * Returns an input map contents if a custom map path was specified
     * @param {string} from Input CSS path
     * @returns {?string}
     */
    function getPrevMap(from) {
        if (typeof options.map.prev === 'string') {
            var mapPath = options.map.prev + path.basename(from) + '.map';

            if (grunt.file.exists(mapPath)) {
                return grunt.file.read(mapPath);
            }
        }
    }

    /**
     * @param {string} input Input CSS contents
     * @param {string} from Input CSS path
     * @param {string} to Output CSS path
     * @returns {{css: string, map: ?string}}
     */
    function process(input, from, to) {
        return processor.process(input, {
            map: (typeof options.map === 'boolean') ? options.map : {
                prev: getPrevMap(from),
                inline: (typeof options.map.inline === 'boolean') ? options.map.inline : true,
                annotation: (typeof options.map.annotation === 'boolean') ? options.map.annotation : true,
                sourcesContent: (typeof options.map.sourcesContent === 'boolean') ? options.map.sourcesContent : true
            },
            from: from,
            to: to
        });
    }

    /**
     * @param {string} msg Log message
     */
    function log(msg) {
        if (!options.silent) {
            grunt.log.writeln(msg);
        }
    }

    grunt.registerMultiTask('postcss', 'Process CSS files.', function() {
        processor = postcss();

        options = this.options({
            diff: false,
            map: false,
            processors: [],
            silent: false
        });

        options.processors.forEach(processor.use.bind(processor));

        this.files.forEach(function(f) {
            if (!f.src.length) {
                return grunt.fail.warn('No source files were found.');
            }

            f.src
                .forEach(function(filepath) {
                    var dest = f.dest || filepath;
                    var input = grunt.file.read(filepath);
                    var output = process(input, filepath, dest);

                    grunt.file.write(dest, output.css);
                    log('File ' + chalk.cyan(dest) + ' created.');

                    if (output.map) {
                        grunt.file.write(dest + '.map', output.map.toString());
                        log('File ' + chalk.cyan(dest + '.map') + ' created (source map).');
                    }

                    if (options.diff) {
                        var diffPath = (typeof options.diff === 'string') ? options.diff : dest + '.diff';

                        grunt.file.write(diffPath, diff.createPatch(dest, input, output.css));
                        log('File ' + chalk.cyan(diffPath) + ' created (diff).');
                    }
                });
        });
    });
};
