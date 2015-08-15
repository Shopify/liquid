---
title: uniq
---


<p>Removes any duplicate instances of an element in an array.</p>

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{% assign fruits = "orange apple banana apple orange" %}
{{ fruits | split: ' ' | uniq | join: ' ' }}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html%}{% raw %}
orange apple banana
{% endraw %}{% endhighlight %}</div>

