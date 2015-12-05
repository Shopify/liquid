---
title: truncatewords
---


<p>Truncates a string down to 'x' words, where x is the number passed as a parameter. An ellipsis (...) is appended to the truncated string.</p>

| Input                                      | Output |
|:-------------------------------------------|:-------|
| {% raw %}`{{ "The cat came back the very next day" | truncatewords: 4 }}`{% endraw %} | The cat came back...|
