---
title: Handles
---

A handle is used to access the attributes of a Liquid object. By default, the handle is the object's title in lowercase with any spaces and special characters replaced by hyphens (-).

For example, a page with the title "About Us" can be accessed in Liquid via its handle `about-us` as shown below:

{% highlight liquid %}
{% raw %}
<!-- the content of the About Us page -->
{{ pages.about-us.content }}
{% endraw %}
{% endhighlight %}

## Creating handles

An object with the title "Shirt" will automatically be given the handle `shirt`. If there is already an object with the handle `shirt`, the handle will auto-increment. In other words, "Shirt" objects created after the first one will receive the handle `shirt-1`, `shirt-2`, and so on.

Whitespace in titles is replaced by hyphens in handles. For example, the title "My Shiny New Title" will be given the handle `my-shiny-new-title`.

Handles also determine the URL of their corresponding objects. For example, a page with the handle `about-us` would have the url `/pages/about-us`.

Websites often rely on static handles for pages, posts, or objects. To preserve design elements and avoid broken links, if you modify the title of an object, **its handle is not automatically updated**. For example, if you were to change a page title from "About Us" to "About This Website", its handle would still be `about-us`.

You can change an object's handle manually (TK how to change a handle manually)

## Accessing handle attributes

In many cases you may know the handle of a object whose attributes you want to access. You can access its attributes by pluralizing the name of the object, then using either the square bracket ( [ ] ) or dot ( . ) notation.

<div class="code-block code-block--input">
{% highlight liquid %}
{% raw %}
{{ pages.about-us.title }}
{{ pages["about-us"].title }}
{% endraw %}
{% endhighlight %}
</div>

<div class="code-block code-block--output">
{% highlight text %}
About Us
About Us
{% endhighlight %}
</div>

In the example above, notice that we are using `pages` as opposed to `page`.
