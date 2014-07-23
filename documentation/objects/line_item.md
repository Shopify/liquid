---
layout: default
title: line_item

nav:
  group: Liquid Variables
---

# line_item

A <strong>line item</strong> represents a single line in the shopping cart. There is one line item for each distinct product variant in the cart. 

The <code>line_item</code> object can be accessed in all Liquid templates, as well as in notification email templates, the Thank You page of the checkout, as well as in apps such as [Order Printer](http://docs.shopify.com/manual/more/official-shopify-apps/order-printer).

The <code>line_item</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}





{% anchor_link "line_item.id", "line-id" %}

Returns the id of the line item, which is the same as the id of its [variant](/themes/liquid-documentation/objects/variant/).








{% anchor_link "line_item.product", "product" %}

Returns the [product](/themes/liquid-documentation/objects/product/) of the line item.

Example for getting a line item's image:

{% highlight html %}{% raw %}
{{ line_item.product.featured_image |  product_img_url | img_tag }}
{% endraw %}{% endhighlight %}








{% anchor_link "line_item.variant", "variant" %}

Returns the [variant](/themes/liquid-documentation/objects/variant/) of the line item.












{% anchor_link "line_item.title", "title" %}

Returns the title of this line item. <code>line_item.title</code> combines both the line item's <code>product.title</code> and the line item's <code>variant.title</code>, separated by a hyphen.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ line_item.title }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Balloon Shirt - Medium
{% endraw %}{% endhighlight %}
</div>

To output just the product title or variant title, you can access the <code>title</code> of the respective variables. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
Product Title: {{ line_item.product.title }}
Variant Title: {{ line_item.variant.title }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Product Title: Balloon Shirt
Variant Title: Medium
{% endraw %}{% endhighlight %}
</div>















{% anchor_link "line_item.price", "price" %}

Returns the price of the line item's variant. 









{% anchor_link "line_item.line_price", "line-price" %}

Returns the combined price of all the items in the line_item. This is the equivalent of <code>line_item.price</code> times <code>line_item.quantity</code>.









{% anchor_link "line_item.quantity", "quantity" %}

Returns the quantity of the line item. 








{% anchor_link "line_item.grams", "grams" %}

Returns the weight of the line item. Use the [weight_with_unit](/themes/liquid-documentation/filters/additional-filters/#weight_with_unit) filter to format the weight. 









{% anchor_link "line_item.sku", "sku" %}

Returns the SKU of the line item's variant.








{% anchor_link "line_item.vendor", "vendor" %}

Returns the vendor name of the line item's product.











{% anchor_link "line_item.requires_shipping", "requires-shipping" %}

Returns <code>true</code> if the line item requires shipping, or <code>false</code> if it does not. This is set in the variant options in the Products page of the Admin. 














{% anchor_link "line_item.variant_id", "variant-id" %}

Returns the id of the line item's variant. 











{% anchor_link "line_item.product_id", "product-id" %}

Returns the id of the line item's product. 









{% anchor_link "line_item.fulfillment", "fulfillment" %}

Returns the [fulfillment](/themes/liquid-documentation/objects/fulfillment/) of the line item. 




