---
layout: default
title: page_title

nav:
  group: Liquid Variables
---

# page_title 

Returns the title of a **Product**, **Page**, or **Blog Article**, set in their respective Admin pages.

{{ '/themes/page_title.jpg' | image }}


<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ page_title }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
About Us
{% endraw %}{% endhighlight %}
</div>











