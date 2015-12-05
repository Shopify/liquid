---
title: sort
---

Sorts items in an array by a property of an item in the array. The order of the sorted array is case-sensitive.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- products = "a", "b", "A", "B" -->
{% assign products = collection.products | sort: 'title' %}
{% for product in products %}
   {{ product.title }}
{% endfor %}{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
A B a b
{% endraw %}{% endhighlight %}
</div>

