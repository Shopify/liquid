---
layout: default
title: linklist

nav:
  group: Liquid Variables
---

# linklist


The <code>linklist</code> object has the following attributes:


<a id="topofpage"></a>
{% table_of_contents %}





{% anchor_link "linklist.handle", "linklist-handle" %}

<p>Returns the <a href="/themes/liquid-documentation/basics/handle/">handle</a> of the linklist.</p>







{% anchor_link "linklist.id", "linklist-id" %}

<p>Returns the id of the linklist.</p>








{% anchor_link "linklist.links", "linklist-links" %}

<p>Returns an array of <a href="/themes/liquid-documentation/objects/link/">links</a> in the linklist.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for link in linklists.main-menu.links %}
      <a href="{{ link.url }}">{{ link.title }}</a>
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="/">Home</a>
<a href="/collections/all">Catalog</a>
<a href="/blogs/news">Blog</a>
<a href="/pages/about-us">About Us</a>
{% endraw %}{% endhighlight %}
</div>











{% anchor_link "linklist.title", "linklist-title" %}

<p>Returns the title of the linklist.</p>


