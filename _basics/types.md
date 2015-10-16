---
title: Types
---

Liquid objects can have one of six types:

- [string](#string)
- [number](#number)
- [boolean](#boolean)
- [nil](#nil)
- [array](#array)
- [EmptyDrop](#emptydrop)

Liquid variables can be initialized by using the [assign](/tags/#assign) or [capture](/tags/#capture) tags.

## String

Strings are declared by wrapping a variable's value in single or double quotes.

{% highlight liquid %}
{% raw %}
{% assign my_string = "Hello World!" %}
{% endraw %}
{% endhighlight %}

## Number

Numbers include floats and integers.

{% highlight liquid %}
{% raw %}
{% assign my_int = 25 %}
{% assign my_float = 39.756 %}
{% endraw %}
{% endhighlight %}

## Boolean

Booleans are either `true` or `false`. No quotations are necessary when declaring a boolean.

{% highlight liquid %}
{% raw %}
{% assign foo = true %}
{% assign bar = false %}
{% endraw %}
{% endhighlight %}

## Nil

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

{% highlight liquid %}{% raw %}
The current user is {{ user.name }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

{% highlight text %}{% raw %}
The current user is
{% endraw %}{% endhighlight %}

## Array

Arrays hold lists of variables of any type.

#### Accessing items in arrays

To access all of the items in an array, you can loop through each item in the array using a [for](/tags/#for) or [tablerow](/tags/#tablerow) tag.

<p class="input">Input</p>
{% highlight liquid %}{% raw %}
<!-- if site.users = "Tobi", "Lina", "Tetsuro", "Adam" -->
{% for user in site.users %}
  {{ user }}
{% endfor %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
{% highlight text %}{% raw %}
Tobi Lina Tetsuro Adam
{% endraw %}{% endhighlight %}


#### Accessing specific items in arrays

You can use square bracket `[ ]` notation to access a specific item in an array. Array indexing starts at zero.

<p class="input">Input</p>
{% highlight liquid %}{% raw %}
<!-- if site.users = "Tobi", "Lina", "Tetsuro", "Adam" -->
{{ site.users[0] }}
{{ site.users[1] }}
{{ site.users[3] }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
{% highlight text %}{% raw %}
Tobi
Lina
Adam
{% endraw %}{% endhighlight %}

#### Initializing arrays

You cannot initialize arrays using pure Liquid.

You can, however, use the [split](/filters/#split) filter to break a single string into an array of substrings.

## EmptyDrop

An EmptyDrop object is returned if you try to access a deleted object (such as a page or post) by its [handle](/basics/#Handles). In the example below, `page_1`, `page_2` and `page_3` are all EmptyDrop objects.

{% highlight liquid %}{% raw %}
{% assign variable = "hello" %}
{% assign page_1 = pages[variable] %}
{% assign page_2 = pages["does-not-exist"] %}
{% assign page_3 = pages.this-handle-does-not-exist %}
{% endraw %}{% endhighlight %}

EmptyDrop objects only have one attribute, `empty?`, which is always *true*.

Collections and pages that *do* exist do not have an `empty?` attribute. Their `empty?` is “falsy”, which means that calling it inside an if statement will return *false*. When using an  unless statement on existing collections and pages, `empty?` will return `true`.

#### Checking for emptiness

Using the `empty?` attribute, you can check to see if an object exists or not before you access any of its attributes.

{% highlight liquid %}{% raw %}
{% unless pages.about.empty? %}
  <!-- This content will only print if the page with handle 'about' is not empty -->
  <h1>{{ pages.frontpage.title }}</h1>
  <div>{{ pages.frontpage.content }}</div>
{% endunless %}
{% endraw %}{% endhighlight %}

If you don't check for emptiness first, Liquid may print empty HTML elements to the page:

{% highlight html %}{% raw %}
<h1></h1>
<div></div>
{% endraw %}{% endhighlight %}
