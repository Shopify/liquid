---
title: floor
---

`floor` rounds the input down to the nearest whole number.

| Input                                      | Output |
|-------------------------------------------:|:-------|
| {% raw %}`{{ 1.2 | floor }}`   {% endraw %} | 1      |
| {% raw %}`{{ 1.7 | floor }}`   {% endraw %} | 1      |
| {% raw %}`{{ 2.0 | floor }}`   {% endraw %} | 2      |
| {% raw %}`{{ "18.3" | floor }}`{% endraw %} | 18     |

It will attempt to cast any input to a number.
