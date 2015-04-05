'use strict';

var fs = require('fs');
var path = require('path');
var postcss = require('postcss');

var csswring = require('../index');

exports['Public API'] = function (test) {
  var expected;
  var input = '.foo{color:black}';
  expected = postcss().process(input).css;

  test.expect(4);

  test.strictEqual(
    csswring.wring(input).css,
    expected
  );

  test.strictEqual(
    csswring().wring(input).css,
    expected
  );

  test.strictEqual(
    postcss().use(csswring.postcss).process(input).css,
    expected
  );

  test.strictEqual(
    postcss().use(csswring().postcss).process(input).css,
    expected
  );

  test.done();
};

exports['Option: PostCSS options'] = function (test) {
  var expected;
  var input = '.foo{color:black}';
  var opts = {
    from: 'from.css',
    map: {
      inline: false
    }
  };
  var processed = csswring.wring(input, opts);
  expected = postcss().process(input, opts);

  test.expect(2);

  test.strictEqual(
    processed.css,
    expected.css
  );

  test.deepEqual(
    processed.map,
    expected.map
  );

  test.done();
};

exports['Option: preserveHacks'] = function (test) {
  var a;
  var b = csswring();
  var expected = '.hacks{*color:black;_background:white;font-size/**/:big}';
  var input = '.hacks{*color:black;_background:white;font-size/**/:big}';
  var opts = {
    preserveHacks: true
  };
  a = csswring(opts);

  test.expect(4);

  test.notStrictEqual(
    csswring.wring(input).css,
    expected
  );

  test.strictEqual(
    csswring(opts).wring(input).css,
    expected
  );

  test.strictEqual(
    csswring.wring(input, opts).css,
    expected
  );

  test.notStrictEqual(
    postcss().use(a.postcss).process(input).css,
    postcss().use(b.postcss).process(input).css
  );

  test.done();
};

exports['Option: removeAllComments'] = function (test) {
  var expected = '.foo{display:block}\n/*# sourceMappingURL=to.css.map */';
  var input = '/*!comment*/.foo{display:block}\n/*# sourceMappingURL=to.css.map */';
  var opts = {
    map: {
      inline: false
    }
  };

  test.expect(2);

  test.notStrictEqual(
    csswring.wring(input, opts).css,
    expected
  );

  test.strictEqual(
    csswring({
      removeAllComments: true
    }).wring(input, opts).css,
    expected
  );

  test.done();
};

exports['Real CSS'] = function (test) {
  var testCases = fs.readdirSync(path.join(__dirname, 'fixtures'));

  var loadExpected = function (file) {
    file = path.join(__dirname, 'expected', file);

    return fs.readFileSync(file, 'utf8').trim();
  };

  var loadInput = function (file) {
    file = path.join(__dirname, 'fixtures', file);

    return fs.readFileSync(file, 'utf8');
  };

  test.expect(testCases.length);

  testCases.forEach(function (testCase) {
    test.strictEqual(
      csswring.wring(loadInput(testCase)).css,
      loadExpected(testCase),
      testCase
    );
  });

  test.done();
};
