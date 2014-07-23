---
layout: default
title: forloop

nav:
  group: Liquid Variables
---

# forloop

The <code>forloop</code> object contains attributes of its parent <a href="/themes/liquid-documentation/tags/iteration-tags/#for">for</a> loop. 


{% block "note-information" %}
The <code>forloop</code> object can only be used within <a href="/themes/liquid-documentation/tags/iteration-tags/#for">for</a> tags.  
{% endblock %}



<a id="topofpage"></a>

{% table_of_contents %}





{% anchor_link "forloop.first", "first" %}

Returns <code>true</code> if it's the first iteration of the for loop. Returns <code>false</code> if it is not the first iteration. 

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% for product in collections.frontpage.products %}
	{% if forloop.first == true %}
		First time through!
	{% else %}
		Not the first time.
	{% endif %}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
First time through!
Not the first time. 
Not the first time. 
Not the first time. 
Not the first time.
{% endraw %}{% endhighlight %}
</div>



      







{% anchor_link "forloop.index", "index" %}

Returns the current index of the for loop, starting at 1. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for product in collections.frontpage.products %}
	{{ forloop.index }}
{% endfor %}{% endraw %}{% endhighlight %}
</div>       

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "forloop.index0", "index0" %}
      
Returns the current index of the for loop, starting at 0. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for product in collections.frontpage.products %}
	{{ forloop.index }}
{% endfor %}{% endraw %}{% endhighlight %}
</div>       

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
{% endraw %}{% endhighlight %}
</div>













{% anchor_link "forloop.last", "last" %}
        
Returns <code>true</code> if it's the last iteration of the for loop. Returns <code>false</code> if it is not the last iteration. 


<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% for product in collections.frontpage.products %}
    {% if forloop.last == true %}
        This is the last iteration!
    {% else %}
        Keep going...
    {% endif %}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Keep going... 
Keep going... 
Keep going... 
Keep going... 
Keep going... 
This is the last iteration!
{% endraw %}{% endhighlight %}
</div>











{% anchor_link "forloop.rindex", "rindex" %}

Returns <a href="#index">forloop.index</a> in reverse order.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for product in collections.frontpage.products %}
	{{ forloop.rindex }}
{% endfor %}{% endraw %}{% endhighlight %}
</div>       

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1
{% endraw %}{% endhighlight %}
</div>












{% anchor_link "forloop.rindex0", "rindex0" %}

Returns <a href="#index0">forloop.index0</a> in reverse order.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for product in collections.frontpage.products %}
	{{ forloop.rindex0 }}
{% endfor %}{% endraw %}{% endhighlight %}
</div>       

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
{% endraw %}{% endhighlight %}
</div>









 {% anchor_link "forloop.length", "length" %}   

<p>Returns the number of iterations of the for loop.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- if collections.frontpage.products contains 10 products -->
{% for product in collections.frontpage.products %}
	{% capture length %}{{ forloop.length }}{% endcapture %}
{% endfor %}

{{ length }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
10
{% endraw %}{% endhighlight %}
</div>




      
    
  
