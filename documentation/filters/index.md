---
layout: default
title: Filters
landing_as_article: true

nav:
  group: Liquid Documentation
  weight: 3
---

# Filters 

Filters are simple methods that modify the output of numbers, strings, variables and objects. They are placed within an output tag <code>&#123;&#123;</code> <code>&#125;&#125;</code> and are separated with a pipe character <code>|</code>. 

<p class="input">Input</p>
{% highlight html %}{% raw %}
<!-- product.title = "Awesome Shoes" -->
{{ product.title | upcase }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
AWESOME SHOES
{% endraw %}{% endhighlight %}
</div>


In the example above, `product` is the object, `title` is its attribute, and `upcase` is the filter being applied. 

Some filters require a parameter to be passed. 

<p class="input">Input</p>
<!-- product.title = "Awesome Shoes" -->
{% highlight html %}{% raw %}
{{ product.title | remove: "Awesome" }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
{% highlight html %}{% raw %}
Shoes
{% endraw %}{% endhighlight %}

Multiple filters can be used on one output. They are applied from left to right. 

<p class="input">Input</p>
{% highlight html %}{% raw %}
<!-- product.title = "Awesome Shoes" -->
{{ product.title | upcase | remove: "AWESOME"  }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
{% highlight html %}{% raw %}
SHOES
{% endraw %}{% endhighlight %}
