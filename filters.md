---
title: Filters
permalink: /filters/
layout: page
---

{% for doc in site.filters %}
<h3 class="component-link" id="{{ doc.title }}">{{ doc.title }}</h3>
<div>
  <span class="right">
    <a href="https://github.com/Shopify/liquid/edit/gh-pages/{{ doc.relative_path }}">
      Improve documentation for {{doc.title}}.
    </a>
  </span>
  {{ doc.output }}
</div>
{% endfor %}
