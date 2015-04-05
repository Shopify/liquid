---
title: join
---

`join` joins the elements of an array, using the character you provide.

| Code                                                   | Output             |
|-------------------------------------------------------:|:-------------------|
| {% raw %}`{{ product.tags | join: ', ' }}`{% endraw %}     | `"sale, mens, womens, awesome` |

In the sample above, assume that `product.tags` resolves to: `["sale", "mens", "womens", "awesome"]`.
