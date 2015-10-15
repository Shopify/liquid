---
title: strip_html
---

<p>Strips all HTML tags from a string.</p>

<p class="input">Input</p>

| Code                                                   | Output             |
|:-------------------------------------------------------|:-------------------|
| {% raw %}`{{ "<h1>Hello</h1> World" | strip_html }}`{% endraw %}     | `Hello World` |
