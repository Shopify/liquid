---
layout: default
title: tax_line

nav:
  group: Liquid Variables
---

# tax_line

The  <code>tax_line</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}



{% anchor_link "tax_line.title", "tax_line-title" %}

Returns the title of the tax. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ tax_line.title }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
GST
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "tax_line.price", "tax_line-price" %}

Returns the amount of the tax. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.


<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ tax_line.price | money }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
€25
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "tax_line.rate", "tax_line-rate" %}

Returns the rate of the tax in decimal notation. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
 {{ tax_line.rate }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
0.14
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "tax_line.rate_percentage", "tax_line-rate_percentage" %}

Returns the rate of the tax in percentage format. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ tax_line.rate_percentage }}%
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
14%
{% endraw %}{% endhighlight %}
</div>




