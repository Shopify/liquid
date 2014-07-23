---
layout: default
title: Math Filters
nav:
  group: Filters
  weight: '4'
---

# Math Filters

Math filters allow you to apply mathematical tasks.

Math filters can be linked and, as with any other filters, are applied in order of left to right. In the example below, <code>minus</code> is applied first, then <code>times</code>, and finally <code>divided_by</code>.

<div>
{% highlight html %}{% raw %}
You save {{ product.compare_at_price | minus: product.price | times: 100.0 | divided_by: product.compare_at_price }}%
{% endraw %}{% endhighlight %}
</div>


{% table_of_contents %}


{% anchor_link "ceil", "ceil" %}

Rounds an output up to the nearest integer.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 4.6 | ceil }} 
{{ 4.3 | ceil }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
5
5
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "divided_by", "divided_by" %}

<p>Divides an output by a number.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- product.price = 200 -->
{{ product.price | divided_by: 10 }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
20
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "floor", "floor" %}

Rounds an output down to the nearest integer.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 4.6 | floor }}
{{ 4.3 | floor }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
4
4
{% endraw %}{% endhighlight %}
</div>












{% anchor_link "minus", "minus" %}

<p>Subtracts a number from an output.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- product.price = 200 -->
{{ product.price | minus: 15 }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
185
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "plus", "plus" %}

<p>Adds a number to an output.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- product.price = 200 -->
{{ product.price | plus: 15 }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
215
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "round", "round" %}

Rounds the output to the nearest integer or specified number of decimals.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 4.6 | round }}
{{ 4.3 | round }}
{{ 4.5612 | round: 2 }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
5
4
4.56
{% endraw %}{% endhighlight %}
</div>












{% anchor_link "times", "times" %}

<p>Multiplies an output by a number.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- product.price = 200 -->
{{ product.price | time: 1.15 }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
230
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "modulo", "modulo" %}

<p>Divides an output by a number and returns the remainder.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 12 | modulo:5 }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
2
{% endraw %}{% endhighlight %}
</div>





