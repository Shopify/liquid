---
title: Filters
type: index
---

**Filters** change the output of a Liquid object. You can append one or more filters to an object by separating the filter and its parameters by a pipe symbol `|`.

{% assign filter_pages = site.pages | where: 'type', 'filter' %}

{% for item in filter_pages %}
## [{{ item.title }}]({{ item.url }})

{{ item.content }}
{% endfor %}
