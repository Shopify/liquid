---
category: control-flow
---


## case/when

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
