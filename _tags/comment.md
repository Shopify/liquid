---
title: Comment
description: An overview of comment tags in the Liquid template language.
---

Allows you to leave un-rendered code inside a Liquid template. Any text within the opening and closing `comment` blocks will not be printed, and any Liquid code within will not be executed.

<p class="code-label">Input</p>
```liquid
{% raw %}
Anything you put between {% comment %} and {% endcomment %} tags
is turned into a comment.
{% endraw %}
```

<p class="code-label">Output</p>
```liquid
Anything you put between {% comment %} and {% endcomment %} tags
is turned into a comment.
```
