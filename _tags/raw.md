---
title: Raw
description: An overview of raw tags in the Liquid template language.
---

Raw temporarily disables tag processing. This is useful for generating content
(eg, Mustache, Handlebars) which uses conflicting syntax.

<p class="code-label">Input</p>
<pre class="highlight">
<code>{% raw %}
&#123;&#37; raw &#37;&#125;
  In Handlebars, {{ this }} will be HTML-escaped, but
  {{{ that }}} will not.
&#123;&#37; endraw &#37;&#125;
{% endraw %}</code>
</pre>

<p class="code-label">Output</p>
```text
{% raw %}In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not.{% endraw %}
```
