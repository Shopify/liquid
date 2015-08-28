---
title: Handles
---

### What is a handle

The handle is used to access the attributes of a Liquid object. By default, it is the object's title in lowercase with any spaces and special characters replaced by hyphens (-). 

For example, a page with the title "About Us" can be accessed in Liquid via its handle <tt>about-us</tt> as shown below:

{% highlight html %}{% raw %}
<!-- the content of the About Us page -->
{{ pages.about-us.content }}
{% endraw %}{% endhighlight %} 

### How are my handles created?

A product with the title "Shirt" will automatically be given the handle **shirt**. If there is already a product with the handle "Shirt", the handle will auto-increment. In other words, all "Shirt" products created after the first one will receive the handle **shirt-1**, **shirt-2**, and so on. 

{{ '/themes/handle-2.jpg' | image }}

Whitespaces in a title are replaced by hyphens in the handle. For example, the title "*My Shiny New Title*" will result in a handle called **my-shiny-new-title**.

{{ '/themes/handle-3.jpg' | image }}

The handle will also determine the URL of that object. For example, a page with the handle "about-us" would have the url: [http://yourshop.myshopify.com/pages/about-us](http://yourshop.myshopify.com/pages/about-us)

Shop designs often rely on a static handle for a page, product, or linklist. In order to preserve design elements and avoid broken links, if you modify the title of an object, **Shopify will not automatically update the handle.** 

For example, if you were to change your page title from "About Us" to "About Shopify" ...

{{ '/themes/handle-4.jpg' | image }}

... your handle will still be **about-us**.

{{ '/themes/handle-5.jpg' | image }}

However, you can change an object's handle manually by changing the value for the "URL & Handle" text box. 

{{ '/themes/handle-6.jpg' | image }}



## Accessing attributes via the handle", "attributes-handle


In many cases you may know the handle of a object whose attributes you want to access. You can access its attributes by pluralizing the name of the object, then using either the square bracket ( [ ] ) or dot ( . ) notation. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ pages.about-us.title }} 
{{ pages["about-us"].title }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
About Us
About Us
{% endraw %}{% endhighlight %}
</div>

In the example above, notice that we are using <code>pages</code> as opposed to <code>page</code>. 

You can also pass in Customize theme page objects using this notation. This is handy for theme designers who wish to give the users of their themes the ability to select which content to display in their theme. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for product in collections[settings.home_featured_collection].products %}
	{{ product.title }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Awesome Shoes
Cool T-Shirt
Wicked Socks
{% endraw %}{% endhighlight %}
</div>




