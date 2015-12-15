---
title: upcase
---

Makes each character in a string uppercase. It has no effect on strings which are already all uppercase.

```liquid
{% raw %}
{{ "Parker Moore" | upcase }}
{% endraw %}
```

```text
{{ "Parker Moore" | upcase }}
```

```liquid
{% raw %}
{{ "APPLE" | upcase }}
{% endraw %}
```

```text
{{ "APPLE" | upcase }}
```
