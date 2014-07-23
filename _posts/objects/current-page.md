---
layout: default
title: current_page

nav:
  group: Liquid Variables
---

# current_page

<code>current_page</code> returns the number of the page you are on when browsing through <a href="/themes/liquid-documentation/tags/theme-tags/#paginate">paginated</a> content. It can be used outside the <code>paginate</code> block.

<p class="input">Input</p>

{% highlight html %}{% raw %}
{{ page_title }} - Page: {{ current_page }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Summer Collection - Page: 1
{% endraw %}{% endhighlight %}
</div>

