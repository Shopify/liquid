---
title: squish
description: Liquid filter that removes all whitespace on both ends of the string, and then changes remaining consecutive whitespace groups into one space each.
---

Remove all whitespace on both ends of the string, and then change remaining consecutive whitespace groups into one space each. `squish` is commonly used
to dynamically create a list of classes or inline styles.

<p class="code-label">Input</p>
```liquid
{%- raw -%}
{% capture styles %}
  --background: {% if section.settings.use_primary_background %}#ffffff{% else %}#000000{% endif %};
  --border-radius: {% if section.settings.use_rounded %}10{% else %}0{% endif %}px;
{% endcapture %}

{% capture class %}
  card
  {% if section.settings.show_compact_card %}
    card--compact
  {% endif %}
{% endcapture %}

<div style="{{ styles | squish }}" class="{{ class | squish }}">
</div>
```

<p class="code-label">Output</p>
```text
<div style="--background: #ffffff; --border-radius: 10px" class="card card--compact">
</div>
```
