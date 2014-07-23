---
layout: default
title: Array Filters
nav:
  group: Filters
  weight: 4
---

# Array Filters

Array filters are used to modify the output of arrays. 

<a id="topofpage"></a>
{% table_of_contents %}




{% anchor_link "join", "join" %}

<p>Joins the elements of an array with the character passed as the parameter. The result is a single string.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ product.tags | join: ', ' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html%}{% raw %}
tag1, tag2, tag3
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "first", "first" %}

<p>Returns the first element of an array.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
<!-- product.tags = "sale", "mens", "womens", "awesome" -->
{{ product.tags | first }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
sale
{% endraw %}{% endhighlight %}
</div>


<code>first</code> can be used in dot notation, in cases where it needs to be used inside a <a href="/themes/liquid-documentation/tags/">tag</a>. 

<div>
{% highlight html %}{% raw %}
{% if product.tags.first == "sale" %}
	This product is on sale!
{% endif %}
{% endraw %}{% endhighlight %}
</div>

Using <code>first</code> on a string returns the first character in the string.

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
<!-- product.title = "Awesome Shoes" -->
{{ product.title | first }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
A
{% endraw %}{% endhighlight %}
</div>











{% anchor_link "last", "last" %}

<p>Gets the last element passed in an array.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
<!-- product.tags = "sale", "mens", "womens", "awesome" -->
{{ product.tags | last }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
awesome
{% endraw %}{% endhighlight %}
</div>

<code>last</code> can be used in dot notation, in cases where it needs to be used inside a <a href="/themes/liquid-documentation/tags/">tag</a>. 

<div>
{% highlight html %}{% raw %}
{% if product.tags.last == "sale"%}
	This product is on sale!
{% endif %}
{% endraw %}{% endhighlight %}
</div>

Using <code>last</code> on a string returns the last character in the string.

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
<!-- product.title = "Awesome Shoes" -->
{{ product.title | last }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
s
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "map", "map" %}

Accepts an array element's attribute as a parameter and creates a string out of each array element's value. 
	
<p class="input">Input</p>

{% highlight html %}{% raw %}
<!-- collection.title = "Spring", "Summer", "Fall", "Winter" -->
{% assign collection_titles = collections | map: 'title' %}
{{ collection_titles }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
SpringSummerFallWinter
{% endraw %}{% endhighlight %}
</div>












{% anchor_link "size", "size" %}

<p>Returns the size of a string or an array.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'this is a 30 character string' | size }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html%}{% raw %}
30
{% endraw %}{% endhighlight %}
</div>

<code>size</code> can be used in dot notation, in cases where it needs to be used inside a <a href="/themes/liquid-documentation/tags/">tag</a>. 

<div>
{% highlight html %}{% raw %}
{% if collections.frontpage.products.size > 10 %}
	There are more than 10 products in this collection! 
{% endif %}
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "sort", "sort" %}

Sorts the elements of an array by a given attribute of an element in the array.

<div>
{% highlight html %}{% raw %}
{% assign products = collection.products | sort: 'price' %}
{% for product in products %}
	<h4>{{ product.title }}</h4>
{% endfor %}
{% endraw %}{% endhighlight %}
</div>




