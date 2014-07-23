---
layout: default
title: product

nav:
  group: Liquid Variables
---

# product

The  <code>product</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}



{% anchor_link "product.available", "product-available" %}

<p>Returns <code>true</code> if a product is available for purchase. Returns <code>false</code>if all of the products variants' <a href="/themes/liquid-documentation/objects/variant/#variant.inventory_quantity">inventory_quantity</a> values are zero or less, and their <a href="/themes/liquid-documentation/objects/variant/#variant.inventory_policy">inventory_policy</a> is not set to "Allow users to purchase this item, even if it is no longer in stock."</p>








{% anchor_link "product.collections", "product-collections" %}

<p>Returns an array of all of the <a href="/themes/liquid-documentation/objects/collection/">collections</a> a product belongs to.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
This product belongs in the following collections:

{% for collection in product.collections %}
	{{ collection.title }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
This product belongs in the following collections:

Sale
Shirts
Spring
{% endraw %}{% endhighlight %}
</div>











{% anchor_link "product.compare_at_price_max", "product-compare_at_price_max" %}

<p>Returns the highest <strong>compare at</strong> price. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>










{% anchor_link "product.compare_at_price_min", "product-compare_at_price_min" %}

<p>Returns the lowest <strong>compare at</strong> price. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>











{% anchor_link "product.compare_at_price_varies", "product-compare_at_price_varies" %}

<p>Returns <code>true</code> if the <code>compare_at_price_min</code> is different from the <code>compare_at_price_max</code>. Returns <code>false</code> if they are the same.</p>













{% anchor_link "product.content", "product-content" %}

<p>Returns the description of the product. Alias for <a href="#product.description">product.description</a>.</p>








{% anchor_link "product.description", "product-description" %}

<p>Returns the description of the product.</p>









{% anchor_link "product.featured_image", "product-featured_image" %}

<p>Returns the relative URL of the product's featured <a href="/themes/liquid-documentation/objects/image/">image</a>.</p>











{% anchor_link "product.handle", "product-handle" %}

Returns the <a href="/themes/liquid-documentation/basics/handle/">handle</a> of a product. 










{% anchor_link "product.id", "product-id" %}

<p>Returns the id of the product.</p>









{% anchor_link "product.images", "product-images" %}

Returns an array of the product's <a href="/themes/liquid-documentation/objects/image/">images</a>. Use the <a href="/themes/liquid-documentation/filters/url-filters/#product_img_url">product_img_url</a> filter to link to the product image on Shopify's Content Delivery Network. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for image in product.images %}
	<img src="{{ image.src | product_img_url: 'medium' }}">
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<img src="//cdn.shopify.com/s/files/1/0087/0462/products/shirt14_medium.jpeg?v=1309278311" />
<img src="http://cdn.shopify.com/s/files/1/0087/0462/products/nice_shirt_medium.jpeg?v=1331480777">
<img src="http://cdn.shopify.com/s/files/1/0087/0462/products/aloha_shirt_medium.jpeg?v=1331481001">
{% endraw %}{% endhighlight %}
</div>











{% anchor_link "product.options", "product-options" %}

<p>Returns an array of the product's options.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for option in product.options %}
	{{ option }} 
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Color Size Material
{% endraw %}{% endhighlight %}
</div>

Use <a href="/themes/liquid-documentation/filters/array-filters/#size">size</a> if you need to determine how many options a product has.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ product.options.size }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
3
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "product.price", "product-price" %}

<p>Returns the price of the product. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>








{% anchor_link "product.price_max", "product-price_max" %}

<p>Returns the highest price of the product. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>









{% anchor_link "product.price_min", "product-price_min" %}

<p>Returns the lowest price of the product. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.</p>









{% anchor_link "product.price_varies", "product-price_varies" %}

<p>Returns <code>true</code> if the product's variants have varying prices. Returns <code>false</code> if all of the product's variants have the same price.</p>








{% anchor_link "product.tags", "product-tags" %}

<p>Returns an array of all of the product's tags. The tags are returned in alphabetical order.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for tag in product.tags %}
    {{ tag }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
new
leather
sale
special
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "product.template_suffix", "product-template_suffix" %}

Returns the name of the custom product template assigned to the product, without the <code>product.</code> prefix nor the <code>.liquid</code> suffix. Returns <code>nil</code> if a custom template is not assigned to the product.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- on product.wholesale.liquid -->
{{ product.template_suffix }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
wholesale
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "product.title", "product-title" %}

<p>Returns the title of the product.</p>









{% anchor_link "product.type", "product-type" %}

<p>Returns the type of the product.</p>









{% anchor_link "product.url", "product-url" %}

<p>Returns the relative URL of the product.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ product.url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
/products/awesome-shoes
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "product.variants", "product-variants" %}

<p>Returns an array the product's <a href="/themes/liquid-documentation/objects/variant/">variants</a>.











{% anchor_link "product.vendor", "product-vendor" %}

<p>Returns the vendor of the product. </p>


