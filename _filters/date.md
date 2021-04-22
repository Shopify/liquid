---
title: date
description: Liquid filter that prints and formats dates.
---

Converts a timestamp into another date format. The format for this syntax is the same as [`strftime`](http://strftime.net). The input uses the same format as Ruby's [`Time.parse`](https://ruby-doc.org/stdlib/libdoc/time/rdoc/Time.html#method-c-parse).

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ article.published_at | date: "%a, %b %d, %y" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
Fri, Jul 17, 15
```

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ article.published_at | date: "%Y" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
2015
```

`date` works on strings if they contain well-formatted dates.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ "March 14, 2016" | date: "%b %d, %y" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "March 14, 2016" | date: "%b %d, %y" }}
```

To get the current time, pass the special word `"now"` (or `"today"`) to `date`.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
This page was last updated at {{ "now" | date: "%Y-%m-%d %H:%M" }}.
{% endraw %}
```

<p class="code-label">Output</p>
```text
This page was last updated at {{ "now" | date: "%Y-%m-%d %H:%M" }}.
```

Note that the value will be the current time of when the page was last generated from the template, not when the page is presented to a user if caching or static site generation is involved.
