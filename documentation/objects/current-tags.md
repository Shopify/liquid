---
layout: default
title: current_tags

nav:
  group: Liquid Variables
---

# current_tags

Product tags are used to filter a collection to only show products that contain a specific product tag. Similarly, article tags are used to filter a blog to only show products that contain a specific article tag. The <code>current_tags</code> variable is an array that contains all tags that are being used to filter a collection or blog. 

{% block "note-information" %}
Tags inside the current_tags array will always display in alphabetical order. It is not possible to manually change the order. 
{% endblock %}

<a id="topofpage"></a>
{% table_of_contents %}



{% anchor_link "Inside collection.liquid", "collection" %}

Inside collection.liquid, <code>current_tags</code> contains all <strong>product tags</strong> that are used to filter a collection.

The example below creates a list that displays every tag within every product in a collection.  If the collection is filtered by the tag (i.e. if <code>current_tags</code> **does** contain the tag), the link will remove the filter. If the collection is not currently filtered by the tag (if <code>current_tags</code> **does not** contain the tag), a link will appear to allow the user to do so.

{% highlight html %}{% raw %}
<ul>
{% for tag in collection.all_tags %}
	{% if current_tags contains tag %}
		  <li class="active">{{ tag | link_to_remove_tag: tag }}</li>
	{% else %}
		  <li>{{ tag | link_to_add_tag: tag }}</li>
	{% endif %}
{% endfor %}
</ul>
{% endraw %}{% endhighlight %}









{% anchor_link "Inside blog.liquid", "blog" %}

Inside blog.liquid,  <code>current_tags</code> contains all <strong>article</strong> tags that are used to filter the blog.

The example below adds a breadcrumb that shows which article tag is being used to filter a blog.  If there is a tag being used to filter a blog, the breadcrumb displays the tag name and  provides a link back to the unfiltered blog.

{% highlight html %}{% raw %}
{% if current_tags %}
  <h1>{{ blog.title | link_to: blog.url }} &raquo; {{ current_tags.first }}</h1>
{% else %}
  <h1>{{ blog.title }}</h1>
{% endif %}
{% endraw %}{% endhighlight %}




