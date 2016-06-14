---
title: Tags
type: index
---

**Tags** create the logic and control flow for templates. They are denoted by curly braces and percent signs: {% raw %}`{%` and `%}`{% endraw %}.

The markup used in tags does not produce any visible text. This means that you can assign variables and create conditions and loops without showing any of the Liquid logic on the page.

{% assign tag_pages = site.pages | where: 'type', 'tag' %}

{% for item in tag_pages %}
## [{{ item.title }}]({{ item.url }})

{{ item.content }}
{% endfor %}
