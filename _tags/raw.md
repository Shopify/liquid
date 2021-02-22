---
title: Raw
description: An overview of raw tags in the Liquid template language.
---

Temporarily disables tag processing. This is useful for generating certain content that uses conflicting syntax, such as [Mustache](https://mustache.github.io/) or [Handlebars](https://handlebarsjs.com/).

<p class="code-label">Input</p>
```liquid
{{ "%7B%25+raw+%25%7D" | url_decode }}{% raw %}
In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not.
{% endraw %}{{ "%7B%25+endraw+%25%7D" | url_decode }}
```

<p class="code-label">Output</p>
```text
{% raw %}
In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not.
{% endraw %}
```
