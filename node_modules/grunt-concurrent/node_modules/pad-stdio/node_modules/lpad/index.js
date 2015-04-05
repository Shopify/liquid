'use strict';
var eol = require('os').EOL;

module.exports = function (str, pad) {
	return pad ? pad + String(str).split(eol).join(eol + pad) : str;
};
