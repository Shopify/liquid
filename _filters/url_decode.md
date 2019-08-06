---
title: url_decode
description: Liquid filter that decodes percent-encoded characters in a string.
---

Decodes a string that has been encoded as a URL or by [`url_encode`]({{ '/filters/url_encode' | prepend: site.baseurl }}).

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "%27Stop%21%27+said+Fred" | url_decode }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
'Stop!' said Fred
```
