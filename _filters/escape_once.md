---
title: escape_once
---

Escapes a string without affecting existing escaped entities.

| Code                                                   | Output             |
|-------------------------------------------------------:|:-------------------|
| {% raw %}`{{ "1 < 2 & 3" | escape_once }}`{% endraw %}     | `"1 < 2 & 3"` |
| {% raw %}`{{ "<< Accept & Checkout" | escape_once }}`{% endraw %}     | `"<< Accept & Checkout"` |
| {% raw %}`{{ "Nope" | escape_once }}`{% endraw %}           | `"Nope"` |

It doesn't modify strings that have nothing to escape.
