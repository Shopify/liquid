---
layout: default
title: image

nav:
  group: Liquid Variables
---

# image 

The <code>image</code> object has the following attributes:
	
<a id="topofpage"></a>
{% table_of_contents %}




{% anchor_link "image.alt", "image-alt" %}

<p>Returns the alt tag of the image, set in the <a href="http://docs.shopify.com/support/your-store/products/can-i-add-alt-text-to-my-product-images">Products</a> page of the Admin.</p> 









{% anchor_link "image.id", "image-id" %}

Returns the id of the image.








{% anchor_link "image.product_id", "image-product_id" %}

Returns the id of the image's product.







{% anchor_link "image.position", "image-position" %}

Returns the position of the image, starting at 1. This is the same as outputting <a href="/themes/liquid-documentation/objects/for-loops/#index">forloop.index</a>.








{% anchor_link "image.src", "image-src" %}

Returns the relative path of the product image. This is the same as outputting <code>&#123;&#123; image &#125;&#125;</code>. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for image in product.images %}
	{{ image.src  }}
	{{ image }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
products/my_image.jpg
products/my_image.jpg
{% endraw %}{% endhighlight %}
</div>

To return the URL of the image on Shopify's Content Delivery Network (CDN), use the appropriate <a href="/themes/liquid-documentation/filters/url-filters">URL filter</a>. 

To see a full list of available image sizes, see <a href="/themes/liquid-documentation/filters/url-filters/#size-parameters">image size parameters</a>.

Shown below is an example of loading a product image using the <code>product_img_url</code> filter. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ image | product_img_url: "medium" }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/products/shirt14_medium.jpeg?v=1309278311
{% endraw %}{% endhighlight %}
</div>









