## elsif / else

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
