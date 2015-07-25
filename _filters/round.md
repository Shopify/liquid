---
title: round
---

Rounds the output to the nearest integer or specified number of decimals.

| Input                                      | Output |
|:-------------------------------------------|:-------|
| {% raw %}`{{ 4.6 | round }}`   {% endraw %} | 5      |
| {% raw %}`{{ 4.3 | round }}`   {% endraw %} | 4      |
| {% raw %}`{{ 4.5612 | round: 2 }}`   {% endraw %} | 4.56      |

