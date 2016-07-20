---
title: date
---

Converts a timestamp into another date format. The format for this syntax is the same as [`strftime`](http://strftime.net).

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ article.published_at | date: "%a, %b %d, %y" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
Fri, Jul 17, 15
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ article.published_at | date: "%Y" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
2015
```

`date` works on strings if they contain well-formatted dates:

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "March 14, 2016" | date: "%b %d, %y" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "March 14, 2016" | date: "%b %d, %y" }}
```
