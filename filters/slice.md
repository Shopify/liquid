---
title: slice
---

The <code>slice</code> filter returns a substring, starting at the specified index. An optional second parameter can be passed to specify the length of the substring. If no second parameter is given, a substring of one character will be returned.


| Input                                           | Output |
|:------------------------------------------------|:-------|
| {% raw %}`{{ "hello" | slice: 0 }}`{% endraw %} | h      |
| {% raw %}`{{ "hello" | slice: 1 }}`{% endraw %} | e      |
| {% raw %}`{{ "hello" | slice: 1, 3 }}`{% endraw %} | ell |


If the passed index is negative, it is counted from the end of the string.

| Input                                           | Output |
|:------------------------------------------------|:-------|
| {% raw %}`{{ "hello" | slice: -3, 2  }}`{% endraw %} | ll |

