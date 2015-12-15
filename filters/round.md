---
title: round
---

Rounds an input number to the nearest integer or, if a number is specified as an argument, to that number of decimal places.

```liquid
{% raw %}
{{ 1.2 | round }}
{% endraw %}
```

```text
{{ 1.2 | round }}
```

```liquid
{% raw %}
{{ 2.7 | round }}
{% endraw %}
```

```text
{{ 2.7 | round }}
```

```liquid
{% raw %}
{{ 183.357 | round: 2 }}
{% endraw %}
```

```text
{{ 183.357 | round: 2 }}
```
