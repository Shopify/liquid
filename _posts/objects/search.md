---
layout: default
title: search

nav:
  group: Liquid Variables
---

# search

The <code>search</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}



{% anchor_link "search.performed", "search-performed" %}

Returns <code>true</code> if an HTML form with the attribute <code>action="/search"</code> was submitted successfully. This allows you to show content based on whether a search was performed or not. 

<div>
{% highlight html %}{% raw %}
{% if search.performed %}
	<!-- Show search results -->
{% endif %}
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "search.results", "search-results" %}

Returns an array of matching search result items. The items in the array can be a: 

- <a href="/themes/liquid-documentation/objects/product/">product</a>,
- <a href="/themes/liquid-documentation/objects/article/">article</a>,
- <a href="/themes/liquid-documentation/objects/page/">page</a>. 

You can access the attributes of the above three objects through <code>search.results</code>.

<div>
{% highlight html %}{% raw %}
{% for item in search.results %}      
  <h3>{{ item.title | link_to: item.url }}</h3>
  {% if item.featured_image %}
  <div class="result-image">
    <a href="{{ item.url }}" title="{{ item.title | escape }}">
      {{ item.featured_image.src | product_img_url: 'small' | img_tag: item.featured_image.alt }}
    </a>
  </div>
  {% endif %}
  <span>{{ item.content | strip_html | truncatewords: 40 | highlight: search.terms }}</span>        
{% endfor %}
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "search.results_count", "search-results_count" %}

<p>Returns the number of results found.</p>








{% anchor_link "search.terms", "search-terms" %}

<p>Returns the string that was entered in the search input box. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#highlight">highlight</a> filter  to apply a different style to any instances in the search results that match up with <code>search.terms</code>.</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ item.content | highlight: search.terms }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<!-- If the search term was "Yellow" -->
<strong class="highlight">Yellow</strong> shirts are the best! 
{% endraw %}{% endhighlight %}
</div>









