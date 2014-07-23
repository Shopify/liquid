---
layout: default
title: part

nav:
  group: Liquid Variables
---

# part

Each <code>part</code> returned by the <a href="/themes/liquid-documentation/objects/paginate/#paginate.parts">paginate.parts</a> array represents a link in the pagination's navigation. 

{% block "note-information" %}
The <code>part</code> object is only accessible through the <a href="/themes/liquid-documentation/objects/paginate">paginate</a> object, and can only be used within <a href="/themes/liquid-documentation/tags/theme-tags/#paginate">paginate</a> tags.  
{% endblock %}

The example below shows how the <code>part</code> object's attributes can be accessed through a for loop that goes through the <code>paginate.parts</code> array. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for part in paginate.parts %}
	{% if part.is_link %}
		{{ part.title | link_to: part.url}}
	{% endif %}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<a href="/collections/frontpage?page=1" title="">1</a>
<a href="/collections/frontpage?page=2" title="">2</a>
<a href="/collections/frontpage?page=3" title="">3</a>
{% endraw %}{% endhighlight %}
</div>



The <code>part</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}










{% anchor_link "part.is_link", "part-is_link" %}

Returns <code>true</code> if the part is a link, returns <code>false</code> if it is not. 










{% anchor_link "part.title", "part-title" %}

Returns the title of the part. 













{% anchor_link "part.url", "part-url" %}

Returns the URL of the part. 

