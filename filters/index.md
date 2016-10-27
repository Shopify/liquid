---
title: Filters
type: index
---

**Filters** change the output of a Liquid object. You can append one or more filters to an object by separating the filter and its parameters by a pipe symbol `|`.

{% assign filter_pages = site.pages | where: 'type', 'filter' %}

{% for item in filter_pages %}
    {% capture path %}{{ item.name }}{% endcapture %}
    {% capture content %}{% include_relative {{path}} %}{% endcapture %}
    {% assign lines = content | newline_to_br | split: "<br />" %}

    {% assign content = "" %}
    {% assign counter = 0 %}

    {% for line in lines %}
        {% assign stripped = line | strip_newlines %}
        {% if counter < 2 %}
            {% if stripped == '---' %}
                {% assign counter = counter | plus: 1 %}
                {% continue %}
            {% endif %}
        {% else %}
            {% assign content = content | append: line %}
        {% endif %}
    {% endfor %}

## [{{ item.title }}]({{ item.url | prepend: site.baseurl }})

{{ content }}
{% endfor %}
