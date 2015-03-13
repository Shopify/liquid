---
title: divided_by
---

This filter divides its input by its parameter.

| Code                                              | Output |
|--------------------------------------------------:|:-------|
| {% raw %}`{{ 4 | divided_by: 2 }}`   {% endraw %} | 2      |
| {% raw %}`{{ "16" | divided_by: 4 }}`{% endraw %} | 4      |

It uses `to_number`, which converts to a decimal value unless already a numeric.
