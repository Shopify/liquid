---
layout: default
title: Control Flow Tags
landing_as_article: true

nav:
  group: Liquid Documentation
  weight: 1
---

# Control Flow Tags

Control Flow tags determine which block of code should be executed based on different conditions. 

<a id="topofpage"></a>
{% table_of_contents %}







{% anchor_link "if", "if" %}

<p>Executes a block of code only if a certain condition is met.</p>      

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% if product.title == 'Awesome Shoes' %}
	These shoes are awesome!
{% endif %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
These shoes are awesome!
{% endraw %}{% endhighlight %}
</div>












{% anchor_link "elsif / else", "elsif-else" %}

<p>Adds more conditions within an <code>if</code> or <code>unless</code> block.</p> 

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
	<!-- If customer.name = 'anonymous' -->
  {% if customer.name == 'kevin' %}
    Hey Kevin!
  {% elsif customer.name == 'anonymous' %}
    Hey Anonymous!
  {% else %}
    Hi Stranger!
  {% endif %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Hey Anonymous!
{% endraw %}{% endhighlight %}
</div>


     







{% anchor_link "case/when", "case-when" %}

<p>Creates a switch statement to compare a variable with different values. <code>case</code> initializes the switch statement, and <code>when</code> compares its values.</p>      

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% assign handle = 'cake' %}
{% case handle %}
  {% when 'cake' %}
     This is a cake
  {% when 'cookie' %}
     This is a cookie
  {% else %}
     This is not a cake nor a cookie
{% endcase %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
This is a cake
{% endraw %}{% endhighlight %}
</div>













{% anchor_link "unless", "unless" %}

<p>Similar to <code>if</code>, but executes a block of code only if a certain condition is <strong>not</strong> met.</p>      

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
  {% unless product.title == 'Awesome Shoes' %}
    These shoes are not awesome.
  {% endunless %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
These shoes are not awesome.
{% endraw %}{% endhighlight %}
</div>

This would be the equivalent of doing the following:

<div>
{% highlight html %}{% raw %}
  {% if product.title != 'Awesome Shoes' %}
    These shoes are not awesome.
  {% endif %}
{% endraw %}{% endhighlight %}
</div>













