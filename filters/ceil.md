---
title: ceil
layout: default
---

`ceil` rounds the input up to the nearest whole number.

| Input                                      | Output |
|-------------------------------------------:|:-------|
| {% raw %}`{{ 1.2 | ceil }}`   {% endraw %} | 2      |
| {% raw %}`{{ 1.7 | ceil }}`   {% endraw %} | 2      |
| {% raw %}`{{ 2.0 | ceil }}`   {% endraw %} | 2      |
| {% raw %}`{{ "18.3" | ceil }}`{% endraw %} | 19     |

It will attempt to cast any input to a number.