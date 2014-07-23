---
layout: default
title: shipping_method

nav:
  group: Liquid Variables
---

# shipping_method

The <code>shipping_method</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}


{% anchor_link "shipping_method.handle", "shipping_method-handle" %}

Returns the <a href="/themes/liquid-documentation/basics/handle/">handle</a> of the shipping method. The price of the shipping rate is appended to the end of the handle. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ shipping_method.handle }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
shopify-international-shipping-25.00
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "shipping_method.price", "shipping_method-price" %}

<p>Returns the price of the shipping method. Use a <a href="/themes/liquid-documentation/filters/money-filters/">money filter</a> to return the value in a monetary format.</p>


<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ shipping_method.price | money }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
$15
{% endraw %}{% endhighlight %}
</div>













{% anchor_link "shipping_method.title", "shipping_method-title" %}

Returns the title of the shipping method. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ shipping_method.title }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
International Shipping 
{% endraw %}{% endhighlight %}
</div>




