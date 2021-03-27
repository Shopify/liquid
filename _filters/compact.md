---
title: compact
description: Liquid filter that removes nil values from an array.
version-badge: 4.0.0
---

Removes any `nil` values from an array.

For this example, assume `site.pages` is an array of content pages for a website, and some of these pages have an attribute called `category` that specifies their content category. If we `map` those categories to an array, some of the array items might be `nil` if any pages do not have a `category` attribute.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign site_categories = site.pages | map: "category" %}

{% for category in site_categories %}
- {{ category }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
- business
- celebrities
-
- lifestyle
- sports
-
- technology
```

By using `compact` when we create our `site_categories` array, we can remove all the `nil` values in the array.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% assign site_categories = site.pages | map: "category" | compact %}

{% for category in site_categories %}
- {{ category }}
{% endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
- business
- celebrities
- lifestyle
- sports
- technology
```
