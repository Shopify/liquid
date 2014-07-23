---
layout: default
title: metafield
nav:
  group: Liquid Variables
---

# metafields

The <code>metafields</code> object allows you to store additional information for products, collections, orders, blogs, pages and your shop. You can output metafields on your storefront using Liquid. 

There are several Shopify apps and browser add-ons that make use of the [Shopify API](/api/metafield) to let you manage your metafields:

* [Shopify FD](http://shopify.freakdesign.com.au/#ShopifyFD) to create and edit metafields
* [Custom Fields](http://shopify.freakdesign.com.au/#customfields) to edit your metafields
* [Metafields Editor](http://apps.shopify.com/metafields-editor)
* [Metafields2](http://apps.shopify.com/metafields2)

A metafield consists of a namespace, a key, a value, and a description (optional). Use the namespace to group different metafields together in a logical way. 

You can also specify metafields as either integers or strings. That way, you’ll end up with the right type of data when you use the metafields in your Liquid.

For example, if  you’ve added two metafields to a product, and each metafield has the following attributes:

<table>
  <tr>
     <th>Namespace</th>
     <th>Key</th>
     <th>Value</th>
  </tr>
  <tbody>
    <tr>
      <td>instructions</td>
      <td>Wash</td>
      <td>Cold</td>
    </tr>
   <tr>
      <td>instructions</td>
      <td>Dry</td>
      <td>Tumble</td>
    </tr>
  </tbody>
</table>

You can then use the following Liquid in <tt>product.liquid</tt> to output your metafield:

<p class="input">Input</p>
{% highlight html %}
{% raw %}
{% assign instructions = product.metafields.instructions %}
{% assign key = 'Wash' %}	
<ul>
  <li>Wash: {{ instructions[key] }}</li>
  <li>Wash: {{ instructions['Wash'] }}</li>
  <li>Wash: {{ instructions.Wash }}</li>
</ul> 
{% endraw %}
{% endhighlight %}

<p class="output">Output</p>
{% highlight html %}
Wash: Cold
Wash: Cold
Wash: Cold
{% endhighlight %}

You can use the following in <tt>product.liquid</tt> to output your second metafield:

{% highlight html %}
{% raw %}
{% assign instructions = product.metafields.instructions %}
{% assign key = 'Dry' %}	
<ul>
  <li>Dry: {{ instructions[key] }}</li>
  <li>Dry: {{ instructions['Dry'] }}</li>
  <li>Dry: {{ instructions.Dry }}</li>
</ul> 
{% endraw %}
{% endhighlight %}

If you need to output all metafields with the namespace _instructions_ attached to a given product, use the following Liquid: 

<p class="input">Input</p>
{% highlight html %}
{% raw %}
<ul>
   {% for field in product.metafields.instructions %}
   <li>{{ field | first }}: {{ field | last }}</li>
   {% endfor %}
</ul>
{% endraw %}
{% endhighlight %}

<p class="output">Output</p>
{% highlight html %}
Wash: Cold
Dry: Tumble 
{% endhighlight %}

The key of a metafield is <code>{% raw %}{{ field | first }}{% endraw %}</code>, while the value is <code>{% raw %}{{ field | last }}{% endraw %}</code>.
