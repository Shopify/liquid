---
title: Comment
description: An overview of comments tags in the Liquid template language.
---

Allows you to leave un-rendered code inside a Liquid template. Any text within
the opening and closing `comment` blocks will not be output, and any Liquid code
within will not be executed.

<p class="code-label">Input</p>
```liquid
{% raw %}
Any contents that you put between {% comment %} and {% endcomment %} tags
is turned into a comment.
{% endraw %}
```

<p class="code-label">Output</p>
```liquid
Any contents that you put between {% comment %} and {% endcomment %} tags
is turned into a comment.
```
