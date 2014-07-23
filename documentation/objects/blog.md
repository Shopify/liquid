---
layout: default
title: blog

nav:
  group: Liquid Variables
---

# blog

The <code>blog</code> object has the following attributes:
<a id="topofpage"></a>
{% table_of_contents %}


{% anchor_link "blog.all_tags", "blog-all_tags" %}

Returns all tags of all articles of a blog. This includes tags of articles that are not in the current pagination view. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for tag in blog.all_tags %}
	{{ tag }} 
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
News, Music, Sale, Tips and Tricks  
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "blog.articles", "blog-articles" %}
Returns an array of all articles in a blog. See <a href="/themes/liquid-documentation/objects/article/">this page</a> for a list of all available attributes for <code>article</code>.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for article in blog.articles %}
	<h2>{{ article.title }}</h2>
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<h2>Hello World!</h2>
<h2>This is my second post.</h2>
<h2>Third time's a charm!</h2>
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "blog.articles_count", "blog-articles_count" %}
Returns the total number of articles in a blog. This total does not include hidden articles. 






{% anchor_link "blog.comments_enabled?", "blog-comments_enabled?" %}
Returns <code>true</code> if comments are enabled, or <code>false</code> if they are disabled.







{% anchor_link "blog.handle", "blog-handle" %}
Returns the <a href="/themes/liquid-documentation/basics/handle/">handle</a> of the blog. 






{% anchor_link "blog.id", "blog-id" %}
Returns the id of the blog.





{% anchor_link "blog.moderated?", "blog-moderated?" %}
Returns <code>true</code> if comments are moderated, or <code>false</code> if they are not moderated.





{% anchor_link "blog.next_article", "blog-next_article" %}
Returns the URL of the next (older) post. Returns "false" if there is no next article. 








{% anchor_link "blog.previous_article", "blog-previous_article" %}

Returns the URL of the previous (newer) post. Returns <code>false</code> if there is no next article. 






{% anchor_link "blog.tags", "blog-tags" %}

Returns all tags in a blog. Similar to <a href="#blog.all_tags">all_tags</a>, but only returns tags of articles that are in the filtered view. 






{% anchor_link "blog.title", "blog-title" %}

Returns the title of the blog. 







{% anchor_link "blog.url", "blog-url" %}

Returns the relative URL of the blog.



