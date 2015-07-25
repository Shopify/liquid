---
title: truncate
---


<p>Truncates a string down to 'x' characters, where x is the number passed as a parameter. An ellipsis (...) is appended to the string and is included in the character count.</p>

| Input                                      | Output |
|:-------------------------------------------|:-------|
| {% raw %}`{{ "The cat came back the very next day" | truncate: 10 }}`{% endraw %} | "The cat..."      |
