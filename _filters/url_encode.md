---
title: url_encode
description: Liquid filter that encodes URL-unsafe characters in a string.
---

Converts any URL-unsafe characters in a string into percent-encoded characters.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "john@liquid.com" | url_encode }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "john@liquid.com" | url_encode }}
```

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "Tetsuro Takara" | url_encode }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "Tetsuro Takara" | url_encode }}
```
