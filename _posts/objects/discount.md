---
layout: default
title: discount

nav:
  group: Liquid Variables
---

# discount

The  <code>discount</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}


{% anchor_link "discount.id", "discount.id" %}

Returns the id of the discount.







{% anchor_link "discount.code", "discount-code" %}

Returns the code of the discount. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ discount.code }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
SPRING14
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "discount.amount", "discount-amount" %}

Returns the amount of the discount. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ discount.amount | money }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
$25
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "discount.savings", "discount-savings" %}

Returns the amount of the discount's savings. The negative opposite of <a href="#discount.amount">amount</a>. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ discount.savings | money }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
$-25
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "discount.type", "discount-type" %}

Returns the type of the discount. The possible values of <code>discount.type</code> are:

- FixedAmountDiscount
- PercentageDiscount
- ShippingDiscount


