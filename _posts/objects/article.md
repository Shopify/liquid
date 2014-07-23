---
layout: default
title: article

nav:
  group: Liquid Variables
---

# article

The <code>article</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}




{% anchor_link "article.author", "article-author" %}

 <p>Returns the full name of the article's author.</p>







{% anchor_link "article.comments", "article-comments" %}

Returns the published <a href="/themes/liquid-documentation/objects/comment/">comments</a> of an article. Returns an empty array if comments are disabled.






{% anchor_link "article.comments_count", "article-comments_count" %}

<p>Returns the number of published comments for an article.</p>







{% anchor_link "article.comments_enabled?", "article-comments_enabled?" %}

<p>Returns <code>true</code> if comments are enabled. Returns <code>false</code> if comments are disabled.</p>







{% anchor_link "article.comment_post_url", "article-comment_post_url" %}

 <p>Returns the relative URL where POST requests are sent to when creating new comments.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ article.comment_post_url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
 /blogs/news/10582441-sale-starts-today/comments
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "article.content", "article-content" %}

<p>Returns the content of an article.</p>








{% anchor_link "article.created_at", "article-created_at" %}
<p>Returns the timestamp of when an article was created. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#date">date filter</a> to format the timestamp.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ article.created_at | date: "%a, %b %d, %y" }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Fri, Sep 16, 11
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "article.excerpt", "article-excerpt" %}
<p>Returns the excerpt of an article.</p>






{% anchor_link "article.excerpt_or_content", "article-excerpt_or_content" %}
 <p>Returns <code>article.excerpt</code> of an article if it exists. Returns <code>article.content</code> if an excerpt does not exist for the article.</p>






{% anchor_link "article.id", "article.id" %}
 <p>Returns the id of an article.</p>





{% anchor_link "article.moderated?", "article-moderated?" %}
  <p>Returns <code>true</code> if the blog that the article belongs to is set to moderate comments. Returns <code>false</code> if the blog is not moderated.</p>






{% anchor_link "article.published_at", "article-published_at" %}
<p>Returns the date/time when an article was published. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#date">date filter</a> to format the timestamp.</p>







{% anchor_link "article.tags", "article-tags" %}
 <p>Returns all the tags for an article.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for tag in article.tags %}
	{{tag}} 
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
tag1 tag2 tag3 tag4
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "article.title", "article-title" %}
<p>Returns the title of an article.</p>







{% anchor_link "article.url", "article-url" %}
<p>Returns the relative URL of the article.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ article.url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
/blogs/news/10582441-my-new-article
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "article.user.account_owner", "article-user-account_owner" %}
<p>Returns "true" if the author of the article is the account owner of the shop. Returns "false" if the author is not the account owner.</p>







{% anchor_link "article.user.bio", "article-user-bio" %}
<p>Returns the bio of the author of an article. This is entered through the <strong>Staff members</strong> options on the <a href="http://www.shopify.com/admin/settings/account">Account</a> page.</p>






{% anchor_link "article.user.email", "article-user-email" %}
<p>Returns the email of the author of an article. This is entered through the <strong>Staff members</strong> options on the <a href="http://www.shopify.com/admin/settings/account">Account</a> page.</p>







{% anchor_link "article.user.first_name", "article-user-first_name" %}
 <p>Returns the first name of the author of an article. This is entered through the <strong>Staff members</strong> options on the <a href="http://www.shopify.com/admin/settings/account">Account</a> page.</p>




{% anchor_link "article.user.last_name", "article-user-last_name" %}
 <p>Returns the last name of the author of an article. This is entered through the <strong>Staff members</strong> options on the <a href="http://www.shopify.com/admin/settings/account">Account</a> page.</p>






{% anchor_link "article.user.homepage", "article-user-homepage" %}
 <p>Returns the homepage of the author of an article. This is entered through the <strong>Staff members</strong> options on the <a href="http://www.shopify.com/admin/settings/account">Account</a> page.</p>









