---
title: Types
---

Liquid objects can return one of six types: String, Number, Boolean, Nil, Array, or EmptyDrop. Liquid variables can be initialized by using the <a href="/themes/liquid-documentation/tags/variable-tags/#assign">assign</a> or <a href="/themes/liquid-documentation/tags/variable-tags/#capture">capture</a> tags. 



### Strings 

Strings are declared by wrapping the variable's value in single or double quotes.

<div>
{% raw %}
{% assign my_string = "Hello World!" %}
{% endraw %}
</div>


### Numbers

Numbers include floats and integers. 

<div>
{% raw %}
{% assign my_num = 25 %}
{% endraw %}
</div>



### Booleans

Booleans are either true or false. No quotations are necessary when declaring a boolean. 

<div>
{% raw %}
{% assign foo = true %}
{% assign bar = false %}
{% endraw %}
</div>



### Nil

Nil is an empty value that is returned when Liquid code has no results. It is **not** a  string with the characters "nil". 

Nil is treated as false in the conditions of &#123;% if %&#125; blocks and other Liquid tags that check for the truthfulness of a statement. The example below shows a situation where a fulfillment does not yet have a tracking number entered. The if statement would not render the included text within it. 

{% raw %}
{% if fulfillment.tracking_numbers %}
We have a tracking number!
{% endif %}
{% endraw %}

Any tags or outputs that return nil will not show anything on the screen. 

<p class="input">Input</p>

{% highlight html %}{% raw %}
Tracking number: {{ fulfillment.tracking_numbers }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Tracking number: 
{% endraw %}{% endhighlight %}
</div>




### Arrays

Arrays hold a list of variables of all types.  

#### Accessing all items in an array

To access items in an array, you can loop through each item in the array using a <a href="/themes/liquid-documentation/tags/#for">for</a> tag or a <a href="/themes/liquid-documentation/tags/#tablerow">tablerow</a> tag. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- if product.tags = "sale", "summer", "spring", "wholesale" -->
{% for tag in product.tags %}
	{{ tag }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
sale summer spring wholesale
{% endraw %}{% endhighlight %}
</div>


#### Accessing a specific item in an array

You can use square brackets ( [ ] ) notation to access a specific item in an array. Array indexing starts at zero. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- if product.tags = "sale", "summer", "spring", "wholesale" -->
{{ product.tags[0] }} 
{{ product.tags[1] }} 
{{ product.tags[2] }} 
{{ product.tags[3] }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
sale
summer
spring
wholesale
{% endraw %}{% endhighlight %}
</div>


#### Initializing an array

It is not possible to initialize an array in Liquid. For example, in Javascript you could do something like this: 

<div>
{% highlight html %}{% raw %}
<script>
var cars = ["Saab", "Volvo", "BMW"];
</script>
{% endraw %}{% endhighlight %}
</div>

In Liquid, you must instead use the <code>split</code> filter to break a single string into an array of substrings. See <a href="/themes/liquid-documentation/filters/string-filters/#split">here</a> for examples. 







## EmptyDrop

An EmptyDrop object is returned whenever you try to access a non-existent object (for example, a collection, page or blog that was deleted or hidden) by [handle](/themes/liquid-documentation/basics/handle). In the example below, <code>page_1</code>, <code>page_2</code> and <code>page_3</code> are all EmptyDrop objects.

{% highlight html %}{% raw %}
{% assign variable = "hello" %}
{% assign page_1 = pages[variable] %}
{% assign page_2 = pages["i-do-not-exist-in-your-store"] %}
{% assign page_3 = pages.this-handle-does-not-belong-to-any-page %}
{% endraw %}{% endhighlight %}

EmptyDrop objects only have one attribute, <code>empty?</code>, which is always true.   

Collections and pages that _do_ exist do not have an <code>empty?</code> attribute. Their <code>empty?</code> is “falsy”, which means that calling it inside an if statement will return <tt>false</tt>. When using an  unless statement on existing collections and pages, <code>empty?</code> will return <tt>true</tt>. 

#### Applications in themes

Using the <code>empty?</code> attribute, you can check to see if a page exists or not _before_ accessing any of its other attributes. 

{% highlight html %}{% raw %}
{% unless pages.frontpage.empty? %}
  <!-- We have a page with handle 'frontpage' and it's not hidden.-->
  <h1>{{ pages.frontpage.title }}</h1>
  <div>{{ pages.frontpage.content }}</div>
{% endunless %}
{% endraw %}{% endhighlight %}

It is important to see if a page exists or not first to avoid outputting empty HTML elements to the page, as follows: 

{% highlight html %}{% raw %}
<h1></h1>
<div></div>
{% endraw %}{% endhighlight %}

You can perform the same verification with collections as well: 

{% highlight html %}{% raw %}
{% unless collections.frontpage.empty? %}
  {% for product in collections.frontpage.products %}
    {% include 'product-grid-item' %}
  {% else %}
    <p>We do have a 'frontpage' collection but it's empty.</p>
  {% endfor %}
{% endunless %}
{% endraw %}{% endhighlight %}







