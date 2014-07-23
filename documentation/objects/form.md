---
layout: default
title: form

nav:
  group: Liquid Variables
---

# form

The <code>form</code> object is used within the <a href="/themes/liquid-documentation/tags/theme-tags/#form">form</a> tag. It contains attributes of its parent form. 



<a id="topofpage"></a>
{% table_of_contents %}





{% anchor_link "form.author", "form-author" %}

 <p>Returns the name of the author of the blog article comment. Exclusive to <code>form</code> tags with the "article" parameter.</p>


	







{% anchor_link "form.body", "form-body" %}

<p>Returns the content of the blog article comment. Exclusive to <code>form</code> tags with the "article" parameter.</p>








{% anchor_link "form.email", "form-email" %}

<p>Returns the email of the blog article comment's author. Exclusive to <code>form</code> tags with the "article" parameter.</p>

<a id="topofpage"></a>
{% table_of_contents %}





{% anchor_link "form.errors", "form-errors" %}

Returns an array of strings if the form was not submitted successfully. The strings returned depend on which fields of the form were left empty or contained errors. Possible values are: 

- author
- body
- email
- form

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for error in form.errors %}
	{{ error }} 
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<!-- if the Name field was left empty by the user -->
author 
{% endraw %}{% endhighlight %}
</div>

You can apply the <a href="/themes/liquid-documentation/filters/additional-filters/#default_errors">default_errors</a> filter on <code>form.errors</code> to output default error messages without having to loop through the array. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% if form.errors %}
      {{ form.errors | default_errors }}
{% endif %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Please enter a valid email address.
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "form.posted_successfully?", "form-posted_successfully" %}

<p>Returns <code>true</code> if a comment by the user was submitted successfully, or <code>false</code> if the form contained errors.</p> 

<div>
{% highlight html %}{% raw %}
{% if form.posted_successfully? %}
	Comment posted successfully!
{% else %}
	{{ form.errors | default_errors }}
{% endif %}
{% endraw %}{% endhighlight %}
</div>






