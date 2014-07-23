---
layout: default
title: paginate

nav:
  group: Liquid Variables
---

# paginate

The <a href="/themes/liquid-documentation/tags/theme-tags/#paginate">paginate</a> tag's navigation is built using the attributes of the <code>paginate</code> object. You can also use the <a href="/themes/liquid-documentation/filters/additional-filters/#default_pagination">default_pagination</a> filter for a quicker alternative. 

{% block "note-information" %}
The <code>paginate</code> object can only be used within <a href="/themes/liquid-documentation/tags/theme-tags/#paginate">paginate</a> tags.  
{% endblock %}


The <code>paginate</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}






{% anchor_link "paginate.current_page", "paginate-current_page" %}

<p>Returns the number of the current page.</p>










{% anchor_link "paginate.current_offset", "paginate-current_offset" %}

<p>Returns the total number of items that are on the pages previous to the current one. For example, if you are paginating by 5 and are on the third page, <code>paginate.current_offset</code> would return <code>10</code>.</p>









{% anchor_link "paginate.items", "paginate-items" %}

<p>Returns the total number of items to be paginated. For example, if you are paginating a collection of 120 products, <code>paginate.items</code> would return <code>120</code>.</p>















{% anchor_link "paginate.parts", "paginate-parts" %}

<p>Returns an array of all <a href="/themes/liquid-documentation/objects/part/">parts</a> of the pagination. A <code>part</code> is a component used to build the navigation for the pagination. 








{% anchor_link "paginate.next", "paginate-next" %}

Returns the <a href="/themes/liquid-documentation/objects/part/">part</a> variable for the <strong>Next</strong> link in the pagination navigation. 

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{% if paginate.next.is_link %}
	<a href="{{ paginate.next.url }}">{{ paginate.next.title }}</a>
{% endif %}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
<!-- If we're not on the last page, and there still needs to be a Next link -->
<a href="/collections/all?page=17">Next »</a>
{% endraw %}{% endhighlight %}</div>












{% anchor_link "paginate.previous", "paginate-previous" %}

Returns the <a href="/themes/liquid-documentation/objects/part/">part</a> variable for the <strong>Previous</strong> link in the pagination navigation. 

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{% if paginate.previous.is_link %}
	<a href="{{ paginate.previous.url }}">{{ paginate.previous.title }}</a>
{% endif %}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
<!-- If we're not on the first page, and there still needs to be a Previous link -->
<a href="/collections/all?page=15">« Previous</a>
{% endraw %}{% endhighlight %}</div>












{% anchor_link "paginate.page_size", "paginate-page_size" %}

Returns the number of items displayed per page. 









{% anchor_link "paginate.pages", "paginate-pages" %}

Returns the number of pages created by the pagination tag.









