---
title: slice
---

Returns a substring of 1 character beginning at the index specified by the argument passed in. An optional second argument specifies the length of the substring to be returned.

String indices are numbered starting from 0.

```liquid
{% raw %}
{{ "Liquid" | slice: 0 }}
{% endraw %}
```

```text
{{ "Liquid" | slice: 0 }}
```

```liquid
{% raw %}
{{ "Liquid" | slice: 2 }}
{% endraw %}
```

```text
{{ "Liquid" | slice: 2 }}
```

```liquid
{% raw %}
{{ "Liquid" | slice: 2, 5 }}
{% endraw %}
```

```text
{{ "Liquid" | slice: 2, 5 }}
```

If the first parameter is a negative number, the indices are counted from the end of the string:

```liquid
{% raw %}
{{ "Liquid" | slice: -3, 2 }}
{% endraw %}
```

```text
{{ "Liquid" | slice: -3, 2 }}
```
