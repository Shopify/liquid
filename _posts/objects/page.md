---
layout: default
title: page

nav:
  group: Liquid Variables
---

# page

The <code>page</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}



{% anchor_link "page.author", "page.author" %}

<p>Returns the author of a page.</p>







{% anchor_link "page.content", "page-content" %}

<p>Returns the content of a page.</p>








{% anchor_link "page.handle", "page-handle" %}

<p>Returns the <a href="/themes/liquid-documentation/basics/handle/">handle</a> of the page. </p>









{% anchor_link "page.id", "page-id" %}

<p>Returns the id of the page.</p>









{% anchor_link "page.published_at", "page-published_at" %}

Returns the timestamp of  when the page was created. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#date">date</a> filter to format the timestamp.










{% anchor_link "page.template_suffix", "page-template_suffix" %}

Returns the name of the custom page template assigned to the page, without the <code>page.</code> prefix nor the <code>.liquid</code> suffix. Returns <code>nil</code> if a custom template is not assigned to the page.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- on page.contact.liquid -->
{{ page.template_suffix }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
contact
{% endraw %}{% endhighlight %}
</div>












{% anchor_link "page.title", "page-title" %}

<p>Returns the title of a page.</p>










{% anchor_link "page.url", "page-url" %}

<p>Returns the relative URL of the page.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ page.url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
/pages/about-us
{% endraw %}{% endhighlight %}
</div>











