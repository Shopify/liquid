---
title: Theme
---


Theme Tags have various functions, including:

- Outputting template-specific HTML markup
- Telling the theme which layout and snippets to use
- Splitting a returned array into multiple pages.


### comment

<p>Allows you to leave un-rendered code inside a Liquid template. Any text within the opening and closing <code>comment</code> blocks will not be output, and any Liquid code within will not be executed.</p>     

<div class="code-block code-block--input">
{% highlight html %}{% raw %}
  My name is {% comment %}super{% endcomment %} Shopify.
{% endraw %}{% endhighlight %}
</div>

<div class="code-block code-block--output">
{% highlight html %}{% raw %}
My name is Shopify.
{% endraw %}{% endhighlight %}
</div>

### include

Inserts a snippet from the **snippets** folder of a theme. 

{% highlight html %}{% raw %}
{% include 'snippet-name' %}
{% endraw %}{% endhighlight %}

Note that the <tt>.liquid</tt> extension is omitted in the above code. 

When a snippet is included, the code inside it will have access to the variables within its parent template. 

<h3 id="multi-variable-snippet">Including multiple variables in a snippet</h3>

There are two ways to include multiple variables in a snippet. You can assign and include them on different lines:

{% highlight html %}{% raw %}
{% assign snippet_variable = 'this is it' %}
{% assign snippet_variable_two = 'this is also it' %}
{% include 'snippet' %}
{% endraw %}{% endhighlight %}

Or you can consolidate them into one line of code:

{% highlight html %}{% raw %}
{% include 'snippet', snippet_variable: 'this is it', snippet_variable_two: 'this is also it' %}
{% endraw %}{% endhighlight %}

<h2 class="parameter">parameters <span>include</span></h2>

### with

The <code>with</code> parameter assigns a value to a variable inside a snippet that shares the same name as the snippet. 

For example, we can have a snippet named **color.liquid** which contains the following:

{% highlight html %}{% raw %}
color: '{{ color }}'
shape: '{{ shape }}'
{% endraw %}{% endhighlight %}

Within **theme.liquid**, we can include the **color.liquid** snippet as follows:

{% highlight html %}{% raw %}
{% assign shape = 'circle' %}
{% include 'color' %}
{% include 'color' with 'red' %}
{% include 'color' with 'blue' %}
{% assign shape = 'square' %}
{% include 'color' with 'red' %}
{% endraw %}{% endhighlight %}

The output will be:

{% highlight html %}{% raw %}
color: shape: 'circle'
color: 'red' shape: 'circle'
color: 'blue' shape: 'circle'
color: 'red' shape: 'square'
{% endraw %}{% endhighlight %}

### form

Creates an HTML <code>&#60;form&#62;</code> element with all the necessary attributes (action, id, etc.) and <code>&#60;input&#62;</code> to submit the form successfully. 

<h2 class="parameter">parameters <span>form</span></h2>

### new_comment

Generates a form for creating a new comment in the <a href="/themes/theme-development/templates/article-liquid/">article.liquid</a> template. Requires the <code>article</code> object as a parameter. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% form "new_comment", article %}
...
{% endform %}
{% endraw %}{% endhighlight %}
</div>


<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<form accept-charset="UTF-8" action="/blogs/news/10582441-my-article/comments" class="comment-form" id="article-10582441-comment-form" method="post">
	<input name="form_type" type="hidden" value="new_comment" />
	<input name="utf8" type="hidden" value="✓" />
	...
</form>
{% endraw %}{% endhighlight %}
</div>

### layout

Loads an alternate template file from the **layout** folder of a theme. If no alternate layout is defined, the **theme.liquid** template is loaded by default. 

{% highlight html %}{% raw %}
<!-- loads the templates/alternate.liquid template -->
{% layout 'alternate' %}
{% endraw %}{% endhighlight %}

If you don't want **any** layout to be used on a specific template, you can use <code>none</code>.

{% highlight html %}{% raw %}
{% layout none %}
{% endraw %}{% endhighlight %}
















### paginate

Splitting products, blog articles, and search results across multiple pages is a necessary component of theme design as you are limited to 50 results per page in any <a href="/themes/liquid-documentation/tags/iteration-tags/#for">for</a> loop. 

The <code>paginate</code> tag works in conjunction with the <code> for </code> tag to split content into numerous pages. It must wrap a <code>for</code> tag block that loops through an array, as shown  in the example below:

{% highlight html %}{% raw %}
{% paginate collection.products by 5 %}  
  {% for product in collection.products %}
    <!--show product details here -->
  {% endfor %}
{% endpaginate %}
{% endraw %}{% endhighlight %}

The <code>by</code> parameter is followed by an integer <strong>between 1 and 50</strong> that tells the <code>paginate</code> tag how many results it should output per page. 


Within <code>paginate</code> tags, you can access attributes of the <a href="/themes/liquid-documentation/objects/paginate/">paginate</a> object. This includes the attributes to output the links required to navigate within the generated pages.


{% comment %}

Accessing any attributes of the array you are paginating <em>before</em> the opening <code>paginate</code> tag will cause errors. To avoid this, make sure any variables 


**Bad Example**
<div>
{% highlight html %}{% raw %}
{{ collection.title }}
{% paginate collection.products by 5 %}  
  {% for product in collection.products %}
		{{ product.title }}
  {% endfor %}
{% endpaginate %}
{% endraw %}{% endhighlight %}
</div>


**Good Example**
<div>
{% highlight html %}{% raw %}
{% paginate collection.products by 5 %}  
  {% for product in collection.products %}
    <!--show product details here -->
  {% endfor %}
{% endpaginate %}
{% endraw %}{% endhighlight %}
</div>

{% endcomment %}




















### raw

<p>Allows output of Liquid code on a page without being parsed.</p>

<p class="input">Input</p>

<div>
<div class="highlight"><pre><code class="html">&#123;% raw %&#125;&#123;&#123; 5 | plus: 6 &#125;&#125;&#123;% endraw %&#125; is equal to 11.</code></pre></div>
</div>

<p class="output">Output</p>

<div>
<div class="highlight"><pre><code class="html">&#123;&#123; 5 | plus: 6 &#125;&#125; is equal to 11.</code></pre></div>
</div>



