---
title: Truthy and Falsy
---

In programming, we describe “truthy” and “falsy” as anything that returns true or  false, respectively, when used inside an if statement.

## What is truthy? 

All values in Liquid are truthy, with the exception of <tt>nil</tt> and <tt>false</tt>. 

In the example below, the text “Tobi” is not a boolean, but it is truthy in a conditional:

{% highlight html %}{% raw %}
{% assign tobi = 'Tobi' %}
{% if tobi %}
This will always be true.
{% endif %}
{% endraw %}{% endhighlight %}

[Strings](/themes/liquid-documentation/basics/types/#strings), even when empty, are truthy. The example below will result in empty HTML tags if <code>settings.fp_heading</code> is empty: 

<p class="input">Input</p>
{% highlight html %}{% raw %}
{% if settings.fp_heading %}
<h1>{{ settings.fp_heading }}</h1>
{% endif %}
{% endraw %}{% endhighlight %}


<p class="output">Output</p>
{% highlight html %}{% raw %}
<h1></h1>
{% endraw %}{% endhighlight %}

To avoid this, you can check to see if the string is <code>blank</code>, as follows: 

<div>
{% highlight html %}{% raw %}
{% unless settings.fp_heading == blank %}
	<h1>{{ settings.fp_heading }}</h1>
{% endunless %}
{% endraw %}{% endhighlight %}
</div>

<hr/>

An [EmptyDrop](/themes/liquid-documentation/basics/types/#empty-drop) is also truthy. In the example below, if <code>settings.page</code> is an empty string or set to a hidden or deleted object, you will end up with an EmptyDrop. The result is an undesirable empty &lt;div&gt;:

<p class="input">Input</p>
{% highlight html %}{% raw %}
{% if pages[settings.page] %}
<div>{{ pages[settings.page].content }}</div>
{% endif %}
{% endraw %}{% endhighlight %}


<p class="output">Output</p>
{% highlight html %}{% raw %}
<div></div>
{% endraw %}{% endhighlight %}


## What is falsy?

The only values that are falsy in Liquid are <tt>nil</tt> and <tt>false</tt>.

[nil](/themes/liquid-documentation/basics/types/#nil) is returned when a Liquid object doesn't have anything to return. For example, if a collection doesn't have a collection image, collection.image will be set to <tt>nil</tt>. Since that is “falsy”, you can do this:

{% highlight html %}{% raw %}
{% if collection.image %}
<!-- output collection image -->
{% endif %}
{% endraw %}{% endhighlight %}

The value <tt>false</tt> is returned through many Liquid object properties such as <tt>product.available</tt>.

## Summary

The table below summarizes what is truthy or falsy in Liquid. 

|               | truthy        | falsy         |
| ------------- |:-------------:|:-------------:|
| true          | &times; |  |
| false         |       | &times; |
| nil          |  | &times; |
| string        | &times;      |     |
| empty string        | &times;     |     |
| 0             |  &times;     |   |
| 1 or 2 or 3.14        | &times;     |     |
| array       |  &times;   |     |
| empty array        |  &times;    |     |
| collection        | &times;     |    |
| collection with no products        | &times;     |     |
| page        | &times;     |     |
| EmptyDrop        | &times;     |     |






















