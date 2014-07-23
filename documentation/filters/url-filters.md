---
layout: default
title: URL Filters
nav:
  group: Filters
  weight: '4'
---

# URL Filters

URL filters output links to assets on Shopify's Content Delivery Network (CDN). They are also used to create links for filtering collections and blogs. 

In many URL filters' outputs, you will see a question mark (?) with a number appended to the asset's file path. This is the file's version number. 

<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/t/394/assets/shop.css?28253
{% endraw %}{% endhighlight %}
</div>

In the example above, <strong>28253</strong> is the version number. URL filters will always load the latest version of an asset. 

{% table_of_contents %}


{% anchor_link "asset_url", "asset_url" %}

Returns the URL of a file in the "assets" folder of a theme.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 'shop.css' | asset_url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/t/394/assets/shop.css?28253
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "file_url", "file_url" %}

<p>Returns the URL of a file in the <a href="http://www.shopify.com/admin/settings/files">Files</a> page of the admin.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 'size-chart.pdf' | file_url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/files/size-chart.pdf?28261
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "customer_login_link", "customer_login_link" %}

Generates a link to the customer log in page.

<p class="input">Input</p>

{% highlight html %}{% raw %}
{{ 'Log in' | customer_login_link }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<a href="/account/login" id="customer_login_link">Log in</a>
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "global_asset_url", "global_asset_url" %}

Returns the URL of a global asset. Global assets are kept in a directory on Shopify's servers. Using global assets can improve the load times of your pages dramatically. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 'prototype.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<script src="//cdn.shopify.com/s/global/prototype.js?1" type="text/javascript"></script>
{% endraw %}{% endhighlight %}
</div>

Listed below are the available global assets:  

{% highlight html %}{% raw %}
{{ 'prototype.js' | global_asset_url | script_tag }}
{{ 'controls.js' | global_asset_url | script_tag }}
{{ 'dragdrop.js' | global_asset_url | script_tag }}
{{ 'effects.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'prototype/1.5/prototype.js' | global_asset_url | script_tag }}
{{ 'prototype/1.6/prototype.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}


{% highlight html %}{% raw %}
{{ 'scriptaculous/1.8.2/scriptaculous.js' | global_asset_url | script_tag }}
{{ 'scriptaculous/1.8.2/builder.js' | global_asset_url | script_tag }}
{{ 'scriptaculous/1.8.2/controls.js' | global_asset_url | script_tag }}
{{ 'scriptaculous/1.8.2/dragdrop.js' | global_asset_url | script_tag }}
{{ 'scriptaculous/1.8.2/effects.js' | global_asset_url | script_tag }}
{{ 'scriptaculous/1.8.2/slider.js' | global_asset_url | script_tag }}
{{ 'scriptaculous/1.8.2/sound.js' | global_asset_url | script_tag }}
{{ 'scriptaculous/1.8.2/unittest.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'ga.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'mootools.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'lightbox.css' | global_asset_url | stylesheet_tag }}
{{ 'lightbox.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'lightbox/v1/lightbox.css' | global_asset_url | stylesheet_tag }}
{{ 'lightbox/v1/lightbox.js' | global_asset_url | script_tag }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'lightbox/v2/lightbox.css' | global_asset_url | stylesheet_tag }}
{{ 'lightbox/v2/lightbox.js' | global_asset_url | script_tag }}
{{ 'lightbox/v2/loading.gif' | global_asset_url }}
{{ 'lightbox/v2/close.gif' | global_asset_url }}
{{ 'lightbox/v2/overlay.png' | global_asset_url }}
{{ 'lightbox/v2/zoom-lg.gif' | global_asset_url }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'lightbox/v204/lightbox.css' | global_asset_url | stylesheet_tag }}
{{ 'lightbox/v204/lightbox.js' | global_asset_url | script_tag }}
{{ 'lightbox/v204/bullet.gif' | global_asset_url }}
{{ 'lightbox/v204/close.gif' | global_asset_url }}
{{ 'lightbox/v204/closelabel.gif' | global_asset_url }}
{{ 'lightbox/v204/donatebutton.gif' | global_asset_url }}
{{ 'lightbox/v204/downloadicon.gif' | global_asset_url }}
{{ 'lightbox/v204/loading.gif' | global_asset_url }}
{{ 'lightbox/v204/nextlabel.gif' | global_asset_url }}
{{ 'lightbox/v204/prevlabel.gif' | global_asset_url }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'list_collection.css' | global_asset_url | stylesheet_tag }}
{{ 'search.css' | global_asset_url | stylesheet_tag }}
{{ 'textile.css' | global_asset_url | stylesheet_tag }}
{% endraw %}{% endhighlight %}

{% highlight html %}{% raw %}
{{ 'firebug/firebug.css' | global_asset_url | stylesheet_tag }}
{{ 'firebug/firebug.js' | global_asset_url | script_tag }}
{{ 'firebug/firebugx.js' | global_asset_url | script_tag }}
{{ 'firebug/firebug.html' | global_asset_url }}
{{ 'firebug/errorIcon.png' | global_asset_url }}
{{ 'firebug/infoIcon.png' | global_asset_url }}
{{ 'firebug/warningIcon.png' | global_asset_url }}
{% endraw %}{% endhighlight %}










{% anchor_link "link_to", "link_to" %}


<p>Generates an HTML link. The first parameter is the URL of the link, and the optional second parameter is the title of the link.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 'Shopify' | link_to: 'http://shopify.com','A link to Shopify' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="http://shopify.com" title="A link to Shopify">Shopify</a>
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "link_to_vendor", "link_to_vendor" %}

Creates an HTML link to a collection page that lists all products belonging to a vendor. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ "Shopify" | link_to_vendor }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="/collections/vendors?q=Shopify" title="Shopify">Shopify</a>
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "link_to_type", "link_to_type" %}

Creates an HTML link to a collection page that lists all products belonging to a product type. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ "jeans" | link_to_type }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="/collections/types?q=jeans" title="jeans">jeans</a>
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "link_to_tag", "link_to_tag" %}

<p>Creates a link to all products in a collection that have a given tag.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- collection.tags = ["Mens", "Womens", "Sale"] -->
{% for tag in collection.tags %}
	{{ tag | link_to_tag: tag }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a title="Show products matching tag Mens" href="/collections/frontpage/mens">Mens</a>
<a title="Show products matching tag Womens" href="/collections/frontpage/womens">Womens</a>
<a title="Show products matching tag Sale" href="/collections/frontpage/sale">Sale</a>

{% endraw %}{% endhighlight %}
</div>






{% anchor_link "link_to_add_tag", "link_to_add_tag" %}

<p>Creates a link to all products in a collection that have a given tag as well as any tags that have been already selected.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- collection.tags = ["Mens", "Womens", "Sale"] -->
{% for tag in collection.tags %}
{{ tag | link_to_add_tag: tag }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<!-- If you're on "/collections/frontpage/mens": --> 
<a title="Show products matching tag Mens" href="/collections/frontpage/mens">Mens</a>
<a title="Show products matching tag Womens" href="/collections/frontpage/womens+mens">Womens</a>
<a title="Show products matching tag Sale" href="/collections/frontpage/sale+mens">Sale</a>
{% endraw %}{% endhighlight %}
</div>





{% anchor_link "link_to_remove_tag", "link_to_remove_tag" %}

<p>Generates a link to all products in a collection that have the given tag and all the previous tags that might have been added already.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- collection.tags = ["Mens", "Womens", "Sale"] -->
{% for tag in collection.tags %}
{{ tag | link_to_add_tag: tag }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<!-- If you're on "/collections/frontpage/mens": --> 
<a title="Remove tag Mens" href="/collections/frontpage">Mens</a>
<a title="Remove tag Womens" href="/collections/frontpage/mens">Womens</a>
<a title="Remove tag Sale" href="/collections/frontpage/mens">Sale</a>
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "payment_type_img_url", "payment_type_img_url" %}

Returns the URL of the payment type's SVG image. Used in conjunction with the <a href="/themes/liquid-documentation/objects/shop/#shop.enabled_payment_types">shop.enabled_payment_types</a> variable. 

<p class="input">Input</p>
{% highlight html %}{% raw %}
{% for type in shop.enabled_payment_types %}
   <img src="{{ type | payment_type_img_url }}" />
{% endfor %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<!-- If shop accepts American Express, MasterCard and Visa -->
<img src="//cdn.shopify.com/s/global/payment_types/creditcards_american_express.svg?3cdcd185ab8e442b12edc11c2cd13655f56b0bb1">
<img src="//cdn.shopify.com/s/global/payment_types/creditcards_master.svg?3cdcd185ab8e442b12edc11c2cd13655f56b0bb1">
<img src="//cdn.shopify.com/s/global/payment_types/creditcards_visa.svg?3cdcd185ab8e442b12edc11c2cd13655f56b0bb1">
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "product_img_url", "product_img_url" %}

<p>Generates the product image URL. Accepts an <a href="/themes/liquid-documentation/filters/url-filters/#size-parameters">image size</a> as a parameter.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ product.featured_image | product_img_url: "medium" }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/products/shirt14_medium.jpeg?v=1309278311
{% endraw %}{% endhighlight %}
</div>

The available size parameters are listed below: 

<h3 id="size-parameters">Parameters: image sizes</h3>

<table>
  <tbody>
    <tr id="pico">
      <td>
        <pre>pico</pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 16 by 16 pixels.</p>
      </td>
    </tr>
    <tr id="icon">
      <td>
        <pre>icon </pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 32 by 32 pixels.</p>
      </td>
    </tr>
    <tr id="thumb">
      <td>
        <pre>thumb</pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 50 by 50 pixels.</p>
      </td>
    </tr>
    <tr id="small">
      <td>
        <pre> small </pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 100 by 100 pixels.</p>
      </td>
    </tr>
	<tr id="compact">
      <td>
        <pre> compact </pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 160 by 160 pixels.</p>
      </td>
    </tr>
	<tr id="medium">
      <td>
        <pre> medium</pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 240 by 240 pixels.</p>
      </td>
    </tr>
	<tr id="large">
      <td>
        <pre> large </pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 480 by 480 pixels.</p>
      </td>
    </tr>
<tr id="grande">
      <td>
        <pre> grande </pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 600 by 600 pixels.</p>
      </td>
    </tr>
<tr id="original">
      <td>
        <pre> original</pre>
      </td>
      <td>
        <p><strong>Deprecated</strong> - do not use this when creating themes. </p>
<p>Returns the image at a maximum size of 1024 by 1024 pixels.</p>
      </td>
    </tr>
<tr id="1024">
      <td>
        <pre>1024x1024</pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 1024 by 1024 pixels.</p>
      </td>
    </tr>
<tr id="2048">
      <td>
        <pre>2048x2048</pre>
      </td>
      <td>
        <p>Returns the image at a maximum size of 2048 by 2048 pixels.</p>
      </td>
    </tr>
<tr id="master">
      <td>
        <pre>master</pre>
      </td>
      <td>
        <p>Returns the largest possible image (the current maximum image size is 2048 x 2048 pixels).</p>
      </td>
    </tr>


    </tbody>
</table>









{% anchor_link "collection_img_url", "collection_img_url" %}

<p>Returns the collection image's URL. Accepts the same <a href="/themes/liquid-documentation/filters/url-filters/#size-parameters">size parameters</a> as <a href="/themes/liquid-documentation/filters/url-filters/#product_img_url">product_img_url</a>.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ collection.image | collection_img_url: 'medium' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
//cdn.shopify.com/s/files/1/0087/0462/collections/collection-image_medium.png?v=1337103726{% endraw %}{% endhighlight %}
</div>










{% anchor_link "shopify_asset_url", "shopify_asset_url" %}

Returns the URL of a global assets that are found on Shopify's servers. Globally-hosted assets include:

- option_selection.js
- api.jquery.js
- shopify_common.js,
- customer_area.js
- currencies.js
- customer.css

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 'option_selection.js' | shopify_asset_url | script_tag }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<script src="//cdn.shopify.com/s/shopify/option_selection.js?20cf2ffc74856c1f49a46f6e0abc4acf6ae5bb34" type="text/javascript"></script>
{% endraw %}{% endhighlight %}
</div>








{% comment %}
{% anchor_link "theme_url", "theme_url" %}

<p>Generates the theme URL.</p>

<div>
{% highlight html %}{% raw %}
{{ theme_role | theme_url }}
{% endraw %}{% endhighlight %}
</div>

This filter outputs a URL that switches the active theme to the given role ("main" or "mobile"). This is the same URL used in the link generated by [link_to_theme](/themes/filters/5-link-to-theme).

See also: [themes](/themes/liquid-variables/themes), [theme](/themes/liquid-variables/theme).


{% endcomment %}


{% comment %}
{% anchor_link "url_for_product", "url_for_product" %}

<p>Generates a URL for a product name by transforming it to a <a href="/themes/liquid-documentation/basics/handle/">handle</a>. <code>url_for_product</code> does not output the actual handle of the product, which could have been edited to something else.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ "Red sportscar" | url_for_product }}
{% endraw %}{% endhighlight %}
</div>



{% endcomment %}



{% anchor_link "url_for_type", "url_for_type" %}

Creates a URL that links to a collection page containing products with a specific product type. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ "T-shirt" | url_for_type }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
/collections/types?q=T-shirt
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "url_for_vendor", "url_for_vendor" %}

Creates a URL that links to a collection page containing products with a specific product vendor. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ "Shopify" | url_for_vendor }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
/collections/vendors?q=Shopify
{% endraw %}{% endhighlight %}
</div>



	



{% anchor_link "within", "within" %}

Creates a <i>collection-aware</i> product URL by prepending "/collections/collection-handle/" to a product URL, where "collection-handle" is the <a href="/themes/liquid-documentation/basics/handle/">handle</a> of the collection that is currently being viewed. 

<p class="input">Input</p>
{% highlight html %}{% raw %}
<a href="{{ product.url | within: collection }}">{{ product.title }}</a>                    
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="/collections/frontpage/products/alien-poster">Alien Poster</a>
{% endraw %}{% endhighlight %}
</div>

When a product is collection-aware, its product template can access the <a href="/themes/liquid-documentation/objects/collection/">collection</a> output of the collection that it belongs to. This allows you to add in collection-related content, such as <a href="http://docs.shopify.com/support/your-store/collections/how-to-navigate-within-a-collection">next/previous product links</a> or <a href="http://docs.shopify.com/support/your-store/products/can-i-recommend-related-products#finding-a-relevant-colleciton">related products</a>. 