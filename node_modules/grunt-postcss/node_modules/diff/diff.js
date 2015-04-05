/* See LICENSE file for terms of use */

/*
 * Text diff implementation.
 *
 * This library supports the following APIS:
 * JsDiff.diffChars: Character by character diff
 * JsDiff.diffWords: Word (as defined by \b regex) diff which ignores whitespace
 * JsDiff.diffLines: Line based diff
 *
 * JsDiff.diffCss: Diff targeted at CSS content
 *
 * These methods are based on the implementation proposed in
 * "An O(ND) Difference Algorithm and its Variations" (Myers, 1986).
 * http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.4.6927
 */
(function(global, undefined) {

  var JsDiff = (function() {
    /*jshint maxparams: 5*/
    /*istanbul ignore next*/
    function map(arr, mapper, that) {
      if (Array.prototype.map) {
        return Array.prototype.map.call(arr, mapper, that);
      }

      var other = new Array(arr.length);

      for (var i = 0, n = arr.length; i < n; i++) {
        other[i] = mapper.call(that, arr[i], i, arr);
      }
      return other;
    }
    function clonePath(path) {
      return { newPos: path.newPos, components: path.components.slice(0) };
    }
    function removeEmpty(array) {
      var ret = [];
      for (var i = 0; i < array.length; i++) {
        if (array[i]) {
          ret.push(array[i]);
        }
      }
      return ret;
    }
    function escapeHTML(s) {
      var n = s;
      n = n.replace(/&/g, '&amp;');
      n = n.replace(/</g, '&lt;');
      n = n.replace(/>/g, '&gt;');
      n = n.replace(/"/g, '&quot;');

      return n;
    }

    function buildValues(components, newString, oldString, useLongestToken) {
      var componentPos = 0,
          componentLen = components.length,
          newPos = 0,
          oldPos = 0;

      for (; componentPos < componentLen; componentPos++) {
        var component = components[componentPos];
        if (!component.removed) {
          if (!component.added && useLongestToken) {
            var value = newString.slice(newPos, newPos + component.count);
            value = map(value, function(value, i) {
              var oldValue = oldString[oldPos + i];
              return oldValue.length > value.length ? oldValue : value;
            });

            component.value = value.join('');
          } else {
            component.value = newString.slice(newPos, newPos + component.count).join('');
          }
          newPos += component.count;

          // Common case
          if (!component.added) {
            oldPos += component.count;
          }
        } else {
          component.value = oldString.slice(oldPos, oldPos + component.count).join('');
          oldPos += component.count;
        }
      }

      return components;
    }

    var Diff = function(ignoreWhitespace) {
      this.ignoreWhitespace = ignoreWhitespace;
    };
    Diff.prototype = {
        diff: function(oldString, newString, callback) {
          var self = this;

          function done(value) {
            if (callback) {
              setTimeout(function() { callback(undefined, value); }, 0);
              return true;
            } else {
              return value;
            }
          }

          // Handle the identity case (this is due to unrolling editLength == 0
          if (newString === oldString) {
            return done([{ value: newString }]);
          }
          if (!newString) {
            return done([{ value: oldString, removed: true }]);
          }
          if (!oldString) {
            return done([{ value: newString, added: true }]);
          }

          newString = this.tokenize(newString);
          oldString = this.tokenize(oldString);

          var newLen = newString.length, oldLen = oldString.length;
          var maxEditLength = newLen + oldLen;
          var bestPath = [{ newPos: -1, components: [] }];

          // Seed editLength = 0, i.e. the content starts with the same values
          var oldPos = this.extractCommon(bestPath[0], newString, oldString, 0);
          if (bestPath[0].newPos+1 >= newLen && oldPos+1 >= oldLen) {
            // Identity per the equality and tokenizer
            return done([{value: newString.join('')}]);
          }

          // Main worker method. checks all permutations of a given edit length for acceptance.
          function execEditLength() {
            for (var diagonalPath = -1*editLength; diagonalPath <= editLength; diagonalPath+=2) {
              var basePath;
              var addPath = bestPath[diagonalPath-1],
                  removePath = bestPath[diagonalPath+1];
              oldPos = (removePath ? removePath.newPos : 0) - diagonalPath;
              if (addPath) {
                // No one else is going to attempt to use this value, clear it
                bestPath[diagonalPath-1] = undefined;
              }

              var canAdd = addPath && addPath.newPos+1 < newLen;
              var canRemove = removePath && 0 <= oldPos && oldPos < oldLen;
              if (!canAdd && !canRemove) {
                // If this path is a terminal then prune
                bestPath[diagonalPath] = undefined;
                continue;
              }

              // Select the diagonal that we want to branch from. We select the prior
              // path whose position in the new string is the farthest from the origin
              // and does not pass the bounds of the diff graph
              if (!canAdd || (canRemove && addPath.newPos < removePath.newPos)) {
                basePath = clonePath(removePath);
                self.pushComponent(basePath.components, undefined, true);
              } else {
                basePath = addPath;   // No need to clone, we've pulled it from the list
                basePath.newPos++;
                self.pushComponent(basePath.components, true, undefined);
              }

              var oldPos = self.extractCommon(basePath, newString, oldString, diagonalPath);

              // If we have hit the end of both strings, then we are done
              if (basePath.newPos+1 >= newLen && oldPos+1 >= oldLen) {
                return done(buildValues(basePath.components, newString, oldString, self.useLongestToken));
              } else {
                // Otherwise track this path as a potential candidate and continue.
                bestPath[diagonalPath] = basePath;
              }
            }

            editLength++;
          }

          // Performs the length of edit iteration. Is a bit fugly as this has to support the
          // sync and async mode which is never fun. Loops over execEditLength until a value
          // is produced.
          var editLength = 1;
          if (callback) {
            (function exec() {
              setTimeout(function() {
                // This should not happen, but we want to be safe.
                /*istanbul ignore next */
                if (editLength > maxEditLength) {
                  return callback();
                }

                if (!execEditLength()) {
                  exec();
                }
              }, 0);
            })();
          } else {
            while(editLength <= maxEditLength) {
              var ret = execEditLength();
              if (ret) {
                return ret;
              }
            }
          }
        },

        pushComponent: function(components, added, removed) {
          var last = components[components.length-1];
          if (last && last.added === added && last.removed === removed) {
            // We need to clone here as the component clone operation is just
            // as shallow array clone
            components[components.length-1] = {count: last.count + 1, added: added, removed: removed };
          } else {
            components.push({count: 1, added: added, removed: removed });
          }
        },
        extractCommon: function(basePath, newString, oldString, diagonalPath) {
          var newLen = newString.length,
              oldLen = oldString.length,
              newPos = basePath.newPos,
              oldPos = newPos - diagonalPath,

              commonCount = 0;
          while (newPos+1 < newLen && oldPos+1 < oldLen && this.equals(newString[newPos+1], oldString[oldPos+1])) {
            newPos++;
            oldPos++;
            commonCount++;
          }

          if (commonCount) {
            basePath.components.push({count: commonCount});
          }

          basePath.newPos = newPos;
          return oldPos;
        },

        equals: function(left, right) {
          var reWhitespace = /\S/;
          return left === right || (this.ignoreWhitespace && !reWhitespace.test(left) && !reWhitespace.test(right));
        },
        tokenize: function(value) {
          return value.split('');
        }
    };

    var CharDiff = new Diff();

    var WordDiff = new Diff(true);
    var WordWithSpaceDiff = new Diff();
    WordDiff.tokenize = WordWithSpaceDiff.tokenize = function(value) {
      return removeEmpty(value.split(/(\s+|\b)/));
    };

    var CssDiff = new Diff(true);
    CssDiff.tokenize = function(value) {
      return removeEmpty(value.split(/([{}:;,]|\s+)/));
    };

    var LineDiff = new Diff();

    var TrimmedLineDiff = new Diff();
    TrimmedLineDiff.ignoreTrim = true;

    LineDiff.tokenize = TrimmedLineDiff.tokenize = function(value) {
      var retLines = [],
          lines = value.split(/^/m);
      for(var i = 0; i < lines.length; i++) {
        var line = lines[i],
            lastLine = lines[i - 1],
            lastLineLastChar = lastLine ? lastLine[lastLine.length - 1] : '';

        // Merge lines that may contain windows new lines
        if (line === '\n' && lastLineLastChar === '\r') {
            retLines[retLines.length - 1] = retLines[retLines.length - 1].slice(0,-1) + '\r\n';
        } else if (line) {
          if (this.ignoreTrim) {
            line = line.trim();
            //add a newline unless this is the last line.
            if (i < lines.length - 1) {
              line += '\n';
            }
          }
          retLines.push(line);
        }
      }

      return retLines;
    };


    var SentenceDiff = new Diff();
    SentenceDiff.tokenize = function (value) {
      return removeEmpty(value.split(/(\S.+?[.!?])(?=\s+|$)/));
    };

    var JsonDiff = new Diff();
    // Discriminate between two lines of pretty-printed, serialized JSON where one of them has a
    // dangling comma and the other doesn't. Turns out including the dangling comma yields the nicest output:
    JsonDiff.useLongestToken = true;
    JsonDiff.tokenize = LineDiff.tokenize;
    JsonDiff.equals = function(left, right) {
      return LineDiff.equals(left.replace(/,([\r\n])/g, '$1'), right.replace(/,([\r\n])/g, '$1'));
    };

    var objectPrototypeToString = Object.prototype.toString;

    // This function handles the presence of circular references by bailing out when encountering an
    // object that is already on the "stack" of items being processed.
    function canonicalize(obj, stack, replacementStack) {
      stack = stack || [];
      replacementStack = replacementStack || [];

      var i;

      for (var i = 0 ; i < stack.length ; i += 1) {
        if (stack[i] === obj) {
          return replacementStack[i];
        }
      }

      var canonicalizedObj;

      if ('[object Array]' === objectPrototypeToString.call(obj)) {
        stack.push(obj);
        canonicalizedObj = new Array(obj.length);
        replacementStack.push(canonicalizedObj);
        for (i = 0 ; i < obj.length ; i += 1) {
          canonicalizedObj[i] = canonicalize(obj[i], stack, replacementStack);
        }
        stack.pop();
        replacementStack.pop();
      } else if (typeof obj === 'object' && obj !== null) {
        stack.push(obj);
        canonicalizedObj = {};
        replacementStack.push(canonicalizedObj);
        var sortedKeys = [];
        for (var key in obj) {
          sortedKeys.push(key);
        }
        sortedKeys.sort();
        for (i = 0 ; i < sortedKeys.length ; i += 1) {
          var key = sortedKeys[i];
          canonicalizedObj[key] = canonicalize(obj[key], stack, replacementStack);
        }
        stack.pop();
        replacementStack.pop();
      } else {
        canonicalizedObj = obj;
      }
      return canonicalizedObj;
    }

    return {
      Diff: Diff,

      diffChars: function(oldStr, newStr, callback) { return CharDiff.diff(oldStr, newStr, callback); },
      diffWords: function(oldStr, newStr, callback) { return WordDiff.diff(oldStr, newStr, callback); },
      diffWordsWithSpace: function(oldStr, newStr, callback) { return WordWithSpaceDiff.diff(oldStr, newStr, callback); },
      diffLines: function(oldStr, newStr, callback) { return LineDiff.diff(oldStr, newStr, callback); },
      diffTrimmedLines: function(oldStr, newStr, callback) { return TrimmedLineDiff.diff(oldStr, newStr, callback); },

      diffSentences: function(oldStr, newStr, callback) { return SentenceDiff.diff(oldStr, newStr, callback); },

      diffCss: function(oldStr, newStr, callback) { return CssDiff.diff(oldStr, newStr, callback); },
      diffJson: function(oldObj, newObj, callback) {
        return JsonDiff.diff(
          typeof oldObj === 'string' ? oldObj : JSON.stringify(canonicalize(oldObj), undefined, '  '),
          typeof newObj === 'string' ? newObj : JSON.stringify(canonicalize(newObj), undefined, '  '),
          callback
        );
      },

      createPatch: function(fileName, oldStr, newStr, oldHeader, newHeader) {
        var ret = [];

        ret.push('Index: ' + fileName);
        ret.push('===================================================================');
        ret.push('--- ' + fileName + (typeof oldHeader === 'undefined' ? '' : '\t' + oldHeader));
        ret.push('+++ ' + fileName + (typeof newHeader === 'undefined' ? '' : '\t' + newHeader));

        var diff = LineDiff.diff(oldStr, newStr);
        if (!diff[diff.length-1].value) {
          diff.pop();   // Remove trailing newline add
        }
        diff.push({value: '', lines: []});   // Append an empty value to make cleanup easier

        function contextLines(lines) {
          return map(lines, function(entry) { return ' ' + entry; });
        }
        function eofNL(curRange, i, current) {
          var last = diff[diff.length-2],
              isLast = i === diff.length-2,
              isLastOfType = i === diff.length-3 && (current.added !== last.added || current.removed !== last.removed);

          // Figure out if this is the last line for the given file and missing NL
          if (!/\n$/.test(current.value) && (isLast || isLastOfType)) {
            curRange.push('\\ No newline at end of file');
          }
        }

        var oldRangeStart = 0, newRangeStart = 0, curRange = [],
            oldLine = 1, newLine = 1;
        for (var i = 0; i < diff.length; i++) {
          var current = diff[i],
              lines = current.lines || current.value.replace(/\n$/, '').split('\n');
          current.lines = lines;

          if (current.added || current.removed) {
            if (!oldRangeStart) {
              var prev = diff[i-1];
              oldRangeStart = oldLine;
              newRangeStart = newLine;

              if (prev) {
                curRange = contextLines(prev.lines.slice(-4));
                oldRangeStart -= curRange.length;
                newRangeStart -= curRange.length;
              }
            }
            curRange.push.apply(curRange, map(lines, function(entry) { return (current.added?'+':'-') + entry; }));
            eofNL(curRange, i, current);

            if (current.added) {
              newLine += lines.length;
            } else {
              oldLine += lines.length;
            }
          } else {
            if (oldRangeStart) {
              // Close out any changes that have been output (or join overlapping)
              if (lines.length <= 8 && i < diff.length-2) {
                // Overlapping
                curRange.push.apply(curRange, contextLines(lines));
              } else {
                // end the range and output
                var contextSize = Math.min(lines.length, 4);
                ret.push(
                    '@@ -' + oldRangeStart + ',' + (oldLine-oldRangeStart+contextSize)
                    + ' +' + newRangeStart + ',' + (newLine-newRangeStart+contextSize)
                    + ' @@');
                ret.push.apply(ret, curRange);
                ret.push.apply(ret, contextLines(lines.slice(0, contextSize)));
                if (lines.length <= 4) {
                  eofNL(ret, i, current);
                }

                oldRangeStart = 0;  newRangeStart = 0; curRange = [];
              }
            }
            oldLine += lines.length;
            newLine += lines.length;
          }
        }

        return ret.join('\n') + '\n';
      },

      applyPatch: function(oldStr, uniDiff) {
        var diffstr = uniDiff.split('\n');
        var diff = [];
        var remEOFNL = false,
            addEOFNL = false;

        for (var i = (diffstr[0][0]==='I'?4:0); i < diffstr.length; i++) {
          if (diffstr[i][0] === '@') {
            var meh = diffstr[i].split(/@@ -(\d+),(\d+) \+(\d+),(\d+) @@/);
            diff.unshift({
              start:meh[3],
              oldlength:meh[2],
              oldlines:[],
              newlength:meh[4],
              newlines:[]
            });
          } else if (diffstr[i][0] === '+') {
            diff[0].newlines.push(diffstr[i].substr(1));
          } else if (diffstr[i][0] === '-') {
            diff[0].oldlines.push(diffstr[i].substr(1));
          } else if (diffstr[i][0] === ' ') {
            diff[0].newlines.push(diffstr[i].substr(1));
            diff[0].oldlines.push(diffstr[i].substr(1));
          } else if (diffstr[i][0] === '\\') {
            if (diffstr[i-1][0] === '+') {
              remEOFNL = true;
            } else if (diffstr[i-1][0] === '-') {
              addEOFNL = true;
            }
          }
        }

        var str = oldStr.split('\n');
        for (var i = diff.length - 1; i >= 0; i--) {
          var d = diff[i];
          for (var j = 0; j < d.oldlength; j++) {
            if (str[d.start-1+j] !== d.oldlines[j]) {
              return false;
            }
          }
          Array.prototype.splice.apply(str,[d.start-1,+d.oldlength].concat(d.newlines));
        }

        if (remEOFNL) {
          while (!str[str.length-1]) {
            str.pop();
          }
        } else if (addEOFNL) {
          str.push('');
        }
        return str.join('\n');
      },

      convertChangesToXML: function(changes){
        var ret = [];
        for ( var i = 0; i < changes.length; i++) {
          var change = changes[i];
          if (change.added) {
            ret.push('<ins>');
          } else if (change.removed) {
            ret.push('<del>');
          }

          ret.push(escapeHTML(change.value));

          if (change.added) {
            ret.push('</ins>');
          } else if (change.removed) {
            ret.push('</del>');
          }
        }
        return ret.join('');
      },

      // See: http://code.google.com/p/google-diff-match-patch/wiki/API
      convertChangesToDMP: function(changes){
        var ret = [], change;
        for ( var i = 0; i < changes.length; i++) {
          change = changes[i];
          ret.push([(change.added ? 1 : change.removed ? -1 : 0), change.value]);
        }
        return ret;
      },

      canonicalize: canonicalize
    };
  })();

  /*istanbul ignore next */
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = JsDiff;
  }
  else if (typeof define === 'function' && define.amd) {
    /*global define */
    define([], function() { return JsDiff; });
  }
  else if (typeof global.JsDiff === 'undefined') {
    global.JsDiff = JsDiff;
  }
})(this);
