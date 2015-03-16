---
title: escape
---

Escapes a string by replacing characters with escape sequences (so that the string can be used in a URI).

| Code                                                   | Output             |
|-------------------------------------------------------:|:-------------------|
| {% raw %}`{{ "Need tips? Ask a friend!" | escape }}`{% endraw %}     | `"Need%20tips%3F%Ask%20a%20friend%21"` |
| {% raw %}`{{ "Nope" | escape }}`{% endraw %}           | `"Nope"` |

It doesn't modify strings that have nothing to escape.
