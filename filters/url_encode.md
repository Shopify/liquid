---
title: url_encode
---

Converts any URL-unsafe characters in a string into percent-encoded characters.

```liquid
{% raw %}
{{ "john@liquid.com" | url_encode }}
{% endraw %}
```

```text
{{ "john@liquid.com" | url_encode }}
```

```liquid
{% raw %}
{{ "Tetsuro Takara" | url_encode }}
{% endraw %}
```

```text
{{ "Tetsuro Takara" | url_encode }}
```
