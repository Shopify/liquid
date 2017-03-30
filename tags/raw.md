---
title: Raw
description: An overview of raw tags in the Liquid template language.
---

Raw temporarily disables tag processing. This is useful for generating content
(eg, Mustache, Handlebars) which uses conflicting syntax.

<p class="code-label">Input</p>
```text
{% raw %}
{% raw %}
  In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not.
{% endraw % }
{% endraw %}
```

<p class="code-label">Output</p>
```liquid
Any contents that you put between {% comment %} and {% endcomment %} tags
is turned into a comment.
```
