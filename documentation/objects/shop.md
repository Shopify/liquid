---
layout: default
title: shop

nav:
  group: Liquid Variables
---

# shop

The <code>shop</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}






{% anchor_link "shop.collections_count", "shop-collections_count" %}

<p>Returns the number of collections in a shop.</p>








{% anchor_link "shop.currency", "shop-currency" %}

<p>Returns the shop's currency in three-letter format (ex: USD).</p>












{% anchor_link "shop.description", "shop-description" %}

<p>Returns the description of the shop.</p>











{% anchor_link "shop.domain", "shop-domain" %}

<p>Returns the primary domain of the shop.</p>












{% anchor_link "shop.email", "shop-email" %}

<p>Returns the shop's email address.</p>









{% anchor_link "shop.enabled_payment_types", "shop-enabled_payment_types" %}

<p>Returns an array of accepted credit cards for the shop. Use the <a href="/themes/liquid-documentation/filters/url-filters/#payment_type_img_url">payment_type_img_url</a> filter to link to the SVG image file of the credit card.</p>              

The available values for this array are:

- visa
- master
- american_express
- paypal
- jcb
- diners_club
- maestro
- google_wallet
- discover
- solo
- switch
- laser
- dankort
- forbrugsforeningen
- dwolla
- bitcoin











{% anchor_link "shop.metafields", "shop-metafields" %}

<p>Returns the shop's metafields. Metafields can only be set using the Shopify API .</p>











{% anchor_link "shop.money_format", "shop-money_format" %}

<p>Returns a string that is used by Shopify to format money without showing the currency.</p>













{% anchor_link "shop.money_with_currency", "shop-money_with_currency" %}

<p>Returns a string that is used by Shopify to format money while also displaying the currency.</p>










{% anchor_link "shop.name", "shop-name" %}

<p>Returns the shop's name.</p>











{% anchor_link "shop.permanent_domain", "shop-permanent_domain" %}

<p>Returns the <strong>.myshopify.com</strong> URL of a shop.</p>











{% anchor_link "shop.products_count", "shop-products_count" %}

<p>Returns the number of products in a shop.</p>










{% anchor_link "shop.types", "shop-types" %}

<p>Returns an array of all unique product types in a shop.</p>

{% highlight html %}{% raw %}
{% for product_type in shop.types %}
  {{ product_type | link_to_type }}
{% endfor %}
{% endraw %}{% endhighlight %}










{% anchor_link "shop.url", "shop-url" %}

<p>Returns the full URL of a shop.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ shop.url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
http://johns-apparel.com 
{% endraw %}{% endhighlight %}
</div>











{% anchor_link "shop.vendors", "shop-vendors" %}

<p>Returns an array of all unique vendors in a shop.</p>

{% highlight html %}{% raw %}
{% for product_vendor in shop.vendors %}
  {{ product_vendor | link_to_vendor }}
{% endfor %}
{% endraw %}{% endhighlight %}











