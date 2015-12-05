---
title: size
---

<p>Returns the size of a string or an array.</p>


| Code                                                   | Output             |
|:-------------------------------------------------------|:-------------------|
| {% raw %}`{{ 'is this a 30 character string?' | size }}`{% endraw %}     | `30` |


`size` can be used in dot notation, in cases where it needs to be used inside a tag.

<div>
{% highlight html %}{% raw %}
{% if collections.frontpage.products.size > 10 %}
  There are more than 10 products in this collection!
{% endif %}
{% endraw %}{% endhighlight %}
</div>
