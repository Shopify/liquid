---
title: escape
---

Escapes a string by replacing some characters with escape sequences (so that the string can be used in a URL, for example). It doesn't change strings that have nothing to escape.

```liquid
{% raw %}
{{ "Have you read 'James & the Giant Peach'?" | escape }}
{% endraw %}
```

```text
{{ "Have you read 'James & the Giant Peach'?" | escape }}
```

```liquid
{% raw %}
{{ "Tetsuro Takara" | escape }}
{% endraw %}
```

```text
{{ "Tetsuro Takara" | escape }}
```
