---
title: Types
---

Liquid objects can return one of six types:

- [string](#string)
- [number](#number)
- boolean
- nil
- array
- EmptyDrop

Liquid variables can be initialized by using the [assign](/tags/#assign) or [capture](/tags/#capture) tags.

### String

Strings are declared by wrapping a variable's value in single or double quotes.

{% highlight liquid %}
{% raw %}
{% assign my_string = "Hello World!" %}
{% endraw %}
{% endhighlight %}

### Number

Numbers include floats and integers.

{% highlight liquid %}
{% raw %}
{% assign my_int = 25 %}
{% assign my_float = 39.756 %}
{% endraw %}
{% endhighlight %}

### Booleans

Booleans are either `true` or `false`. No quotations are necessary when declaring a boolean.

{% highlight liquid %}
{% raw %}
{% assign foo = true %}
{% assign bar = false %}
{% endraw %}
{% endhighlight %}

### Nil

Nil is a special empty value that is returned when Liquid code has no results. It is **not** a string with the characters "nil".

Nil is treated as false in the conditions of `if` blocks and other Liquid tags that check the truthfulness of a statement.

In the following example, if the user does not exist (that is, `user` returns `nil`), Liquid will not print the greeting:

{% highlight liquid %}
{% raw %}
{% if user %}
  Hello {{ user.name }}!
{% endif %}
{% endraw %}
{% endhighlight %}

Tags or outputs that return `nil` will not print anything to the page.

<p class="input">Input</p>

{% highlight html %}{% raw %}
The current user is {{ user.name }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

{% highlight html %}{% raw %}
The current user is
{% endraw %}{% endhighlight %}

### Arrays

Arrays hold lists of variables of any type.

#### Accessing items in arrays

To access items in an array, you can loop through each item in the array using a [for](/tags/#for) or [tablerow](/tags/#tablerow) tag.

<p class="input">Input</p>
{% highlight html %}{% raw %}
<!-- if site.users = "Tobi", "Lina", "Tetsuro", "Adam" -->
{% for user in site.users %}
  {{ user }}
{% endfor %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
{% highlight html %}{% raw %}
Tobi Lina Tetsuro Adam
{% endraw %}{% endhighlight %}


#### Accessing a specific item in an array

You can use square bracket `[ ]` notation to access a specific item in an array. Array indexing starts at zero.

<p class="input">Input</p>
{% highlight html %}{% raw %}
<!-- if site.users = "Tobi", "Lina", "Tetsuro", "Adam" -->
{{ site.users[0] }}
{{ site.users[1] }}
{{ site.users[3] }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
{% highlight html %}{% raw %}
Tobi
Lina
Adam
{% endraw %}{% endhighlight %}

#### Initializing an array

It is not possible to initialize an array using only Liquid.

You can, howver, use the [split](/filters/#split) filter to break a single string into an array of substrings.

## EmptyDrop

An EmptyDrop object is returned whenever you try to access a non-existent object (for example, a collection, page or blog that was deleted or hidden) by [handle](/basics/#Handles). In the example below, `page_1`, `page_2` and `page_3` are all EmptyDrop objects.

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







