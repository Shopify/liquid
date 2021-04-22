---
title: capitalize
description: Liquid filter that capitalizes the first character of a string and downcases the remaining characters.
---

Makes the first character of a string capitalized and converts the remaining characters to lowercase.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "title" | capitalize }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "title" | capitalize }}
```

Only the first character of a string is capitalized, so later words are not capitalized:

 <p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "my GREAT title" | capitalize }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "my GREAT title" | capitalize }}
```
