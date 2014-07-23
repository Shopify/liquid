---
layout: default
title: variant

nav:
  group: Liquid Variables
---

# variant

The <code>variant</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}




{% anchor_link "variant.available", "variant-available" %}

Returns <code>true</code> if the variant is available to be purchased, or <code>false</code> if it not. In order for a variant to be available, its <code>variant.inventory_quantity</code> must be greater than zero and its <code>variant.inventory_policy</code> must be <code>continue</code>. 









{% anchor_link "variant.barcode", "variant-barcode" %}

<p>Returns the variant's barcode.</p>










{% anchor_link "variant.compare_at_price", "variant-compare_at_price" %}

<p>Returns the variant's compare at price.  Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>











{% anchor_link "variant.id", "variant-id" %}

<p>Returns the variant's unique id.</p>









{% anchor_link "variant.inventory_management", "variant-inventory_management" %}

<p>Returns the variant's inventory tracking service.</p>






{% anchor_link "variant.inventory_policy", "variant-inventory_policy" %}

Returns the string <code>continue</code> if the "Allow users to purchase this item, even if it is no longer in stock." checkbox is checked in the variant options in the Admin. Returns <code>deny</code> if it is unchecked. 







{% anchor_link "variant.inventory_quantity", "variant-inventory_quantity" %}

<p>Returns the variant's inventory quantity.</p>










{% anchor_link "variant.option1", "variant-option1" %}

Returns the value of the variant's first option. 










{% anchor_link "variant.option2", "variant-option2" %}

Returns the value of the variant's second option. 










{% anchor_link "variant.option3", "variant-option3" %}

Returns the value of the variant's third option. 









{% anchor_link "variant.price", "variant-price" %}

<p>Returns the variant's price.  Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>









{% anchor_link "variant.sku", "variant-sku" %}

<p>Returns the variant's SKU.</p>









{% anchor_link "variant.title", "variant-title" %}

<p>Returns the concatenation of all the variant's option values, joined by a <code>/</code>.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- If variant's option1, option2, and option3 are "Red", "Small", "Wool", respectively -->
{{ variant.title }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Red / Small / Wool
{% endraw %}{% endhighlight %}
</div>











{% anchor_link "variant.weight", "variant-weight" %}

<p>Returns the variant's weight. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#weight_with_unit">weight_with_unit</a> filter to convert it to the shop's weight format.</p>




