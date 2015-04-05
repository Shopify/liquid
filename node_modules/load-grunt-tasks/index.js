'use strict';
var path = require('path');
var findup = require('findup-sync');
var multimatch = require('multimatch');

function arrayify(el) {
	return Array.isArray(el) ? el : [el];
}

module.exports = function (grunt, opts) {
	opts = opts || {};

	var pattern = arrayify(opts.pattern || ['grunt-*', '@*/grunt-*']);
	var config = opts.config || findup('package.json');
	var scope = arrayify(opts.scope || ['dependencies', 'devDependencies', 'peerDependencies']);

	if (typeof config === 'string') {
		config = require(path.resolve(config));
	}

	pattern.push('!grunt', '!grunt-cli');

	var names = scope.reduce(function (result, prop) {
		var deps = config[prop] || [];
		return result.concat(Array.isArray(deps) ? deps : Object.keys(deps));
	}, []);

	multimatch(names, pattern).forEach(grunt.loadNpmTasks);
};
