---
layout: default
title: Basics
landing_as_article: true

nav:
  group: Liquid Documentation
  weight: 1
---


# Introduction

Liquid is an open-source, Ruby-based template language created by Shopify. It is the backbone of Shopify themes and is used to load dynamic content on storefronts.  

<iframe width="560" height="315" src="//www.youtube.com/embed/tZLTExLukSg" frameborder="0" allowfullscreen style="margin: 0 auto 24px auto; width: 70%; display: block; padding: 20px 15%; background: #f9f9f9;"></iframe>

Liquid uses a combination of _tags_, _objects_, and _filters_ to load dynamic content. They are used inside Liquid _template files_, which are a group of files that make up a theme. For more information on the available templates, please see <a href="/themes/theme-development/templates/">Theme Development</a>. 

{% table_of_contents %}

{% anchor_link "Tags", "tags" %}

Tags make up the programming logic that tells templates what to do.

{% highlight html %}{% raw %}
{% if user.name == 'elvis' %}
  Hey Elvis
{% endif %}
{% endraw %}{% endhighlight %}

<p class="tr">
<a class="themes-article-cta" href="/themes/liquid-documentation/tags">Read more &rsaquo;</a>
</p>



    






{% anchor_link "Objects", "objects" %}

Objects contain attributes that are used to display dynamic content on the page. 

{% highlight html %}{% raw %}
{{ product.title }} <!-- Output: Awesome T-Shirt-->
{% endraw %}{% endhighlight %}


<p class="tr">
<a class="themes-article-cta" href="/themes/liquid-documentation/objects">Read more &rsaquo;</a>
</p>








{% anchor_link "Filters", "filters" %}

Filters are used to modify the output of strings, numbers, variables, and objects. 

{% highlight html %}{% raw %}
{{ 'sales' | append: '.jpg' }} <!-- Output: sales.jpg -->
{% endraw %}{% endhighlight %}
<p class="tr">
<a class="themes-article-cta" href="/themes/liquid-documentation/filters">Read more &rsaquo;</a>
</p>