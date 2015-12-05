---
title: url_encode
---

Converts any URL-unsafe characters in a string into percent-encoded characters.

| Code                                                   | Output             |
|:-------------------------------------------------------|:-------------------|
| {% raw %}`{{ 'john@liquid.com' | url_encode }}`{% endraw %}     | `john%40liquid.com` |
