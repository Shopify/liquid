---
title: Control Flow
---

## case/when

<p>Creates a switch statement to compare a variable with different values. <code>case</code> initializes the switch statement, and <code>when</code> compares its values.</p>

<div class="code-block code-block--input">
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

<div class="code-block code-block--output">
{% highlight html %}{% raw %}
This is a cake
{% endraw %}{% endhighlight %}
</div>

## if

<p>Executes a block of code only if a certain condition is met.</p>

<div class="code-block code-block--input">
{% highlight html %}{% raw %}
{% if product.title == 'Awesome Shoes' %}
  These shoes are awesome!
{% endif %}
{% endraw %}{% endhighlight %}
</div>


<div class="code-block code-block--output">
{% highlight html %}{% raw %}
These shoes are awesome!
{% endraw %}{% endhighlight %}
</div>

## elsif / else

<p>Adds more conditions within an <code>if</code> or <code>unless</code> block.</p>


<div class="code-block code-block--input">
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

<div class="code-block code-block--output">
{% highlight html %}{% raw %}
Hey Anonymous!
{% endraw %}{% endhighlight %}
</div>

## unless

<p>Similar to <code>if</code>, but executes a block of code only if a certain condition is <strong>not</strong> met.</p>

<div class="code-block code-block--input">
{% highlight html %}{% raw %}
  {% unless product.title == 'Awesome Shoes' %}
    These shoes are not awesome.
  {% endunless %}
{% endraw %}{% endhighlight %}
</div>

<div class="code-block code-block--input">
{% highlight html %}{% raw %}
These shoes are not awesome.
{% endraw %}{% endhighlight %}
</div>

This would be the equivalent of doing the following:

<div class="code-block code-block--output">
{% highlight html %}{% raw %}
  {% if product.title != 'Awesome Shoes' %}
    These shoes are not awesome.
  {% endif %}
{% endraw %}{% endhighlight %}
</div>
