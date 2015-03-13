---
title: downcase
---

This filter makes the entire input string the lower case version of each character within.

| Code                                                   | Output           |
|-------------------------------------------------------:|:-----------------|
| {% raw %}`{{ "Peter Parker" | downcase }}`{% endraw %} | `"peter parker"` |

It doesn't modify strings which are already entirely lowercase. It works with anything that has a `#to_s` method.
