## unless

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
