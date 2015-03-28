---
title: capitalize
---

`capitalize` ensures the first character of your string is capitalized.

| Input                                                      | Output           |
|-----------------------------------------------------------:|:-----------------|
| {% raw %}`{{ "title" | capitalize }}`         {% endraw %} | "Title"          |
| {% raw %}`{{ "my great title" | capitalize }}`{% endraw %} | "My great title" |

It only capitalizes the first character, so subsequent words will not be capitalized as well.
