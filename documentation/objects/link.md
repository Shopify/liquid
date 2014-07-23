---
layout: default
title: link

nav:
  group: Liquid Variables
---

# link

The <code>link</code> object cannot be invoked on its own. It must be invoked inside a <a href="/themes/liquid-documentation/objects/linklist/">linklist</a>.

The <code>link</code> object has the following attributes:


<a id="topofpage"></a>
{% table_of_contents %}

{% anchor_link "link.active", "link-active" %}

<p>Returns <code>true</code> if the link is active, or <code>false</code> if the link is inactive.</p>

<p>If you are on a product page that is <a href="/themes/liquid-documentation/filters/url-filters/#within">collection-aware</a>, <code>link.active</code>will return <code>true</code> for both the collection-aware product URL and the collection-agnostic URL. For example, if you have a link whose URL points to:</p>

<div>{% highlight html %}{% raw %}
/products/awesome-product
{% endraw %}{% endhighlight %}</div>

<p><code>link.active</code> will return <code>true</code> for the following URL, which links to the same product but through a collection: 

<div>{% highlight html %}{% raw %}
/collections/awesome-collection/products/awesome-product
{% endraw %}{% endhighlight %}</div>

<p>If you are on a collection page filtered with tags, and the link points to the unfiltered collection page, <code>link.active</code> will return <code>true</code>.</p>

 <p>If you are on an article page and your link points to the blog, <code> link.active</code> will return <code>true</code>.</p>









{% anchor_link "link.object", "link-object" %}

Returns the variable associated to the link. The type of variable that is returned is dependent on the value of <strong>Links To</strong> field of the link. The possible types are:

- <a href="/themes/liquid-documentation/objects/product/">product</a>
- <a href="/themes/liquid-documentation/objects/collection/">collection</a>
- <a href="/themes/liquid-documentation/objects/page/">page</a>
- <a href="/themes/liquid-documentation/objects/blog/">blog</a>

Through <code>link.object</code>, you can access any of the attributes that are available in the above three variables.

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
<!-- If the product links to a product with a price of $10 -->
{{ link.object.price | money }}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
$10
{% endraw %}{% endhighlight %}</div>











{% anchor_link "link.title", "link-title" %}

<p>Returns the title of the link.</p>





{% anchor_link "link.type", "link-type" %}

Returns the type of the link. The possible values are:

- <strong>collection_link</strong>: if the link points to a collection
- <strong>product_link</strong>: if the link points to a product page
- <strong>page_link</strong>: if the link points to a page
- <strong>blog_link</strong>: if the link points to a blog
- <strong>relative_link</strong>: if the link points to the search page, the home page or /collections/all
- <strong>http_link</strong>: if the link points to an external web page, or a type or vendor collection (ex: /collections/types?q=Pants)






{% anchor_link "link.url", "link-url" %}

<p>Returns the URL of the link.</p>


