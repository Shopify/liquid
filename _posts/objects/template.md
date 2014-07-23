---
layout: default
title: template

nav:
  group: Liquid Variables
---

# template

<code>template</code> returns the name of the template used to render the current page, with the <code>.liquid</code> extension omitted. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- If you're on the index.liquid template -->
{{ template }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
index
{% endraw %}{% endhighlight %}
</div>











