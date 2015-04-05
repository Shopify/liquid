'use strict';
var lpad = require('lpad');
var _outWrite = process.stdout.write.bind(process.stdout);
var _errWrite = process.stderr.write.bind(process.stderr);

exports.stdout = function (pad) {
	process.stdout.write = pad ? function (str) { _outWrite(lpad(str, pad)); } : _outWrite;
};

exports.stderr = function (pad) {
	process.stderr.write = pad ? function (str) { _errWrite(lpad(str, pad)); } : _errWrite;
};
