---
layout: default
title: collection

nav:
  group: Liquid Variables
---

# collection

The <code>collection</code> object has the following attributes:


<a id="topofpage"></a>
{% table_of_contents %}





{% comment %}

Commenting out all_products and all_products_count as I don't see a purpose for them atm. The pagination limit for products and all_products is the same, so what is the difference?

{% anchor_link "collection.all_products", "collection.all_products" %}

Returns all of the products inside a collection. Note that there is a limit of 50 products that can be shown per page. Use the <a href="#">pagination</a> tag to control how many products are shown per page. 






{% anchor_link "collection.all_products_count", "collection.all_products_count" %}

<p>Returns the number of products in a collection.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ collection.all_products_count }} {{ collection.all_products_count | pluralize: 'Item', 'Items' }} total
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
24 Items
{% endraw %}{% endhighlight %}
</div>



{% anchor_link "collection.all_tags", "collection.all_tags" %}

Returns all tags of all products of a collection. This includes tags of products that are not in the current pagination view.

{% highlight html %}{% raw %}
{% if collection.all_tags.size > 0 %}
  {% for tag in collection.all_tags %}
  {% if current_tags contains tag %}
  <li class="active">
    {{ tag | link_to_remove_tag: tag }}
  </li>
  {% else %}
  <li>
    {{ tag | link_to_tag: tag }}
  </li>
  {% endif %}
  {% endfor %}  
{% endif %}
{% endraw %}{% endhighlight %}



# {% endcomment %}






{% anchor_link "collection.all_types", "collection-all_types" %}

<p>Returns a list of all product types in a collection.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{% for product_type in collection.all_types %}
  {{ product_type | link_to_type }}
{% endfor %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="/collections/types?q=Accessories" title="accessories">Accessories</a>
<a href="/collections/types?q=Chairs" title="Chairs">Chairs</a>
<a href="/collections/types?q=Shoes" title="Shoes">Shoes</a>
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "collection.all_vendors", "collection-all_vendors" %}

<p>Returns a list of all product vendors in a collection.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{% for product_vendor in collection.all_vendors %}
  {{ product_vendor | link_to_vendor }}
{% endfor %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="/collections/vendors?q=Shopify" title="Shopify">Shopify</a>
<a href="/collections/vendors?q=Shirt+Company" title="Shirt Company">Shirt Company</a>
<a href="/collections/vendors?q=Montezuma" title="Montezuma">Montezuma</a>
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "collection.current_type", "collection-current_type" %}

Returns the product type when filtering a collection by type. For example, you may be on a collection page filtered by a type query parameter via this URL: <tt>myshop.shopify.com/collections?types=shirts</tt>. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% if collection.current_type %}
	{{ collection.current_type }}
{% endif %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
shirts
{% endraw %}{% endhighlight %}
</div>



















{% anchor_link "collection.current_vendor", "collection-current_vendor" %}

Returns the vendor name when filtering a collection by vendor. For example, you may be on a collection page filtered by a vendor query parameter via this URL: <tt>myshop.shopify.com/collections/vendors?q=Shopify</tt>. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% if collection.current_vendor %}
	{{ collection.current_vendor }}
{% endif %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Shopify
{% endraw %}{% endhighlight %}
</div>















{% anchor_link "collection.default_sort_by", "collection-default_sort_by" %}

<p>Returns the sort order of the collection, which is set in the collection pages of the Admin.</p>

{{ '/themes/collection-sorting.jpg' | image }}

The possible outputs are: 

- manual
- best-selling
- title-ascending
- title-descending
- price-ascending
- price-descending
- created-ascending
- created-descending











{% anchor_link "collection.description", "collection-description" %}

<p>Returns the description of the collection.</p>







{% anchor_link "collection.handle", "collection-handle" %}

<p>Returns the <a href="/themes/liquid-documentation/basics/handle/">handle</a> of a collection. </p>







{% anchor_link "collection.id", "collection-id" %}

<p>Returns the id of the collection.</p>








{% anchor_link "collection.image", "collection-image" %}

<p>Returns the collection image. Use the <a href="/themes/liquid-documentation/filters/url-filters/#collection_img_url">collection_img_url</a> filter to link it to the image file on the Shopify CDN.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ collection.image | collection_img_url: 'medium' }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/collections/collection-image_medium.png?v=1337103726
{% endraw %}{% endhighlight %}
</div>







{% comment %}
Commenting out since you can't actually change alt tag in admin.
{% anchor_link "collection.image.alt", "collection.image.alt" %}

<p>Returns the collection image's alt tag.</p>


{% endcomment %}






{% anchor_link "collection.image.src", "collection-image-src" %}

<p>Returns the relative URL to the collection image.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ collection.image.src | collection_img_url: 'medium' }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/collections/summer_collection_medium.png?v=1334084726
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "collection.next_product", "collection-next_product" %}

Returns the URL of the next product in the collection. Returns <code>nil</code> if there is no next product.

This output can be used on the product page to output "next" and "previous" links on the <tt>product.liquid</tt> template. For more information, see <a href="http://docs.shopify.com/support/your-store/collections/how-to-navigate-within-a-collection">How to Navigate within a Collection</a>.










{% anchor_link "collection.previous_product", "collection-previous_product" %}

Returns the URL of the previous product in the collection. Returns <code>nil</code> if there is no previous product.

This output can be used on the product page to output "next" and "previous" links on the <tt>product.liquid</tt> template. For more information, see <a href="http://docs.shopify.com/support/your-store/collections/how-to-navigate-within-a-collection">How to Navigate within a Collection</a>.









{% anchor_link "collection.products", "collection-products" %}

Returns all of the products inside a collection. Note that there is a limit of 50 products that can be shown per page. Use the <a href="/themes/liquid-documentation/tags/theme-tags/#paginate">pagination</a> tag to control how many products are shown per page. 








{% anchor_link "collection.products_count", "collection-products_count" %}

<p>Returns the number of products in a collection.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ collection.all_products_count }} {{ collection.all_products_count | pluralize: 'Item', 'Items' }} total
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
24 Items
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "collection.template_suffix", "collection-template_suffix" %}

<p>Returns the name of the custom collection template assigned to the collection, without the <tt>collection.</tt> prefix or the <tt>.liquid</tt> suffix. Returns  <code>nil</code> if a custom template is not assigned to the collection.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ collection.template_suffix }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
no-price
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "collection.title", "collection-title" %}

<p>Returns the title of the collection.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
<h1>{{ collection.title }}</h1>
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Frontpage
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "collection.tags", "collection-tags" %}

<p>Returns all tags of all products in a collection.</p>








{% anchor_link "collection.url", "collection-url" %}

<p>Returns the URL of the collection.</p>







