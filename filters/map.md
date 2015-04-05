---
title: map
---

Collects an array of properties from a hash.

| Code                                                   | Output             |
|-------------------------------------------------------:|:-------------------|
| {% raw %}`{{ product | map: 'tag' }}`{% endraw %}     | `["sale", "mens", "womens", "awesome"]` |

In the sample above, assume that `product` resolves to: `[{ tags: "sale"}, { tags: "mens"}, { tags: "womens"}, { tags: "awesome"}]`.
