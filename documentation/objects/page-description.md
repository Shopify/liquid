---
layout: default
title: page_description

nav:
  group: Liquid Variables
---

# page_description 

Returns the description of a **Product**, **Page**, or **Blog Article**, set in their respective Admin pages.

{{ '/themes/page_desc.jpg' | image }}

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ page_description }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
This is my About Us page!
{% endraw %}{% endhighlight %}
</div>











