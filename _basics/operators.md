---
title: Operators
---

Liquid includes many logical and comparison operators.

### Basic Operators

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
      <td><pre>&gt;</pre></td>
      <td>greater than</td>
    </tr>
    <tr>
      <td><pre>&lt;</pre></td>
      <td>less than</td>
    </tr>
    <tr>
      <td><pre>&gt;=</pre></td>
      <td>greater than or equal to</td>
    </tr>
    <tr>
      <td><pre>&lt;=</pre></td>
      <td>less than or equal to</td>
    </tr>
    <tr>
      <td><pre>or</pre></td>
      <td>logical or</td>
    </tr>
    <tr>
      <td><pre>and</pre></td>
      <td>logical and</td>
    </tr>
  </tbody>
</table>

For example:

<div>
{% highlight liquid %}{% raw %}
{% if product.title == "Awesome Shoes" %}
  These shoes are awesome!
{% endif %}
{% endraw %}{% endhighlight %}
</div>

You can use multiple operators in a tag:

<div>
{% highlight liquid %}{% raw %}
{% if product.type == "Shirt" or product.type == "Shoes" %}
  This is a shirt or a pair of shoes.
{% endif %}
{% endraw %}{% endhighlight %}
</div>

### contains

`contains` checks for the presence of a substring inside a string.

{% highlight liquid %}{% raw %}
{% if product.title contains 'Pack' %}
  This product's title contains the word Pack.
{% endif %}
{% endraw %}{% endhighlight %}

`contains` can also check for the presence of a string in an array of strings.

{% highlight liquid %}{% raw %}
{% if product.tags contains 'Hello' %}
  This product has been tagged with 'Hello'.
{% endif %}
{% endraw %}{% endhighlight %}

`contains` is can only search strings. You cannot use it to check for an object in an array of objects.
