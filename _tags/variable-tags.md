---
title: Variable Tags
---

# Variable Tags

Variable Tags are used to create new Liquid variables. 




### assign

<p>Creates a new variable.</p>      

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
  {% assign my_variable = false %}
  {% if my_variable != true %}
  This statement is valid.
  {% endif %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
	This statement is valid.
{% endraw %}{% endhighlight %}
</div>

Use quotations ("") to save the variable as a string.

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% assign foo = "bar" %}
{{ foo }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
bar
{% endraw %}{% endhighlight %}
</div>


### capture

<p>Captures the string inside of the opening and closing tags and assigns it to a variable. Variables created through {&#37; capture &#37;} are strings.</p>


<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% capture my_variable %}I am being captured.{% endcapture %}
{{ my_variable }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
I am being captured.
{% endraw %}{% endhighlight %}
</div>








































### increment

Creates a new number variable, and increases its value by one every time it is called. The initial value is 0. 

<p class="input">Input</p>

{% highlight html %}{% raw %}
{% increment variable %}
{% increment variable %}
{% increment variable %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
0
1
2
{% endraw %}{% endhighlight %}
</div>

Variables created through the <code>increment</code> tag are independent from variables created through <code>assign</code> or <code>capture</code>. 

In the example below, a variable named "var" is created through <code>assign</code>. The <code>increment</code> tag is then used several times on a variable with the same name. However, note that the <code>increment</code> tag does not affect the value of  "var" that was created through <code>assign</code>.

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% assign var = 10 %}
{% increment var %}
{% increment var %}
{% increment var %}
{{ var }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
0
1
2
10 
{% endraw %}{% endhighlight %}
</div>








### decrement

Creates a new number variable, and decreases its value by one every time it is called. The initial value is -1. 

<p class="input">Input</p>

{% highlight html %}{% raw %}
{% decrement variable %}
{% decrement variable %}
{% decrement variable %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
-1
-2
-3
{% endraw %}{% endhighlight %}
</div>

Like <a href="#increment">increment</a>, variables declared inside <code>decrement</code> are independent from variables created through <code>assign</code> or <code>capture</code>.


        


