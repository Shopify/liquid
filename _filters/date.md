---
title: date
category: aaa
description: Liquid filter that prints and formats dates.
redirect_from: /filters/
---

Converts a timestamp into another date format. The format for this syntax is the same as [`strftime`](http://strftime.net). The input uses the same format as Ruby's [`Time.parse`](https://ruby-doc.org/stdlib/libdoc/time/rdoc/Time.html#method-c-parse).

`date` works on strings if they contain well-formatted dates.
To get the current time, pass the special word `"now"` (or `"today"`) to `date`.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{{ article.published_at | date: "%a, %b %d, %y" }}
{{ article.published_at | date: "%Y" }}
{{ "March 14, 2016" | date: "%b %d, %y" }}
This page was last updated at {{ "now" | date: "%Y-%m-%d %H:%M" }}.
{% endraw %}
```

<p class="code-label">Output</p>
```text
Fri, Jul 17, 15
2015
{{ "March 14, 2016" | date: "%b %d, %y" }}
This page was last updated at {{ "now" | date: "%Y-%m-%d %H:%M" }}.
```

Note: If caching or static site generation is involved, the value will be the moment when the page was last generated from the template, not when the page is presented to a user.
