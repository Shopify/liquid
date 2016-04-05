---
title: abs
---

Returns the absolute value of a number.

```liquid
{% raw %}
{{ -17 | abs }}
{% endraw %}
```

```text
17
```

```liquid
{% raw %}
{{ 4 | abs }}
{% endraw %}
```

```text
4
```

`abs` will also work on a string if the string only contains a number.

```liquid
{% raw %}
{{ "-19.86" | abs }}
{% endraw %}
```

```text
19.86
```
