---
layout: default
title: Operators

nav:
  group: Liquid Variables
  weight: 3
---

# Operators

<a id="topofpage"></a>

Liquid has access to all of the logical and comparison operators. These can be used in tags such as <a href="/themes/liquid-documentation/tags/control-flow-tags/#if">if</a> and <a href="/themes/liquid-documentation/tags/control-flow-tags/#unless">unless</a>.


<a id="topofpage"></a>

{% table_of_contents %}



{% anchor_link "Basic Operators", "basic-operators" %}

<table>
  <tbody>
    <tr>
      <td><pre>==</pre></td>
      <td>equals</td>
    </tr>
    <tr>
      <td><pre>!=</pre></td>
      <td>does not equal</td>
    </tr>
    <tr>
      <td><pre>></pre></td>
      <td>greater than</td>
    </tr>
    <tr>
      <td><pre>&lt;</pre></td>
      <td>less than</td>
    </tr>
    <tr>
      <td><pre>>=</pre></td>
      <td>greater than or equal to</td>    

    </tr>
    <tr>
      <td><pre>&lt;=</pre></td>
      <td>less than or equal to</td>
    </tr>
    <tr>
      <td><pre>or</pre></td>
      <td>condition A <strong>or</strong> condition B</td>
    </tr>
    <tr>
      <td><pre>and</pre></td>
      <td>condition A <strong>and</strong> condition B</td>
    </tr>
    </tbody>
</table>

**Examples:**

<div>
{% highlight html %}{% raw %}
{% if product.title == "Awesome Shoes" %}
	These shoes are awesome!
{% endif %}
{% endraw %}{% endhighlight %}
</div>

Operators can be chained together. 

<div>
{% highlight html %}{% raw %}
{% if product.type == "Shirt" or product.type == "Shoes" %}
	This is a shirt or a shoe. 
{% endif %}
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "The 'contains' Operator", "contains" %}

<code>contains</code> checks for the presence of a substring inside a string.


{% highlight html %}{% raw %}
{% if product.title contains 'Pack' %}
  This product's title contains the word Pack.
{% endif %}
{% endraw %}{% endhighlight %}


<code>contains</code> can also check for the presence of a string in an array of strings.

{% highlight html %}{% raw %}
{% if product.tags contains 'Hello' %}
  This product has been tagged with 'Hello'.
{% endif %}
{% endraw %}{% endhighlight %}


You **cannot** check for the presence of an object in an array of objects using contains. This will not work:

{% highlight html %}{% raw %}
{% if product.collections contains 'Sale' %}
  One of the collections this product belongs to is the Sale collection.
{% endif %}
{% endraw %}{% endhighlight %}

This will work:

{% highlight html %}{% raw %}
{% assign in_sale_collection = false %}
{% for collection in product.collections %}
  {% if in_sale_collection == false and collection.title == 'Sale' %}
    {% assign in_sale_collection = true %}
  {% endif %}
{% endfor %}
{% if in_sale_collection %}
  One of the collections this product belongs to is the Sale collection.
{% endif %}
{% endraw %}{% endhighlight %}

   