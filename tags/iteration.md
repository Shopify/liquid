---
title: Iteration
---

Iteration Tags are used to run a block of code repeatedly.

<a id="topofpage"></a>

### for

Repeatedly executes a block of code. For a full list of attributes available within a `for` loop, see [forloop (object)](/themes/liquid-documentation/objects/for-loops).

`for` loops can output a maximum of 50 results per page. In cases where there are more than 50 results, use the [paginate](/themes/liquid-documentation/tags/theme-tags/#paginate) tag to split them across multiple pages.

<p class="input">Input</p>
<div>
{% highlight liquid %}{% raw %}
  {% for product in collection.products %}
    {{ product.title }}
  {% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight text %}
hat shirt pants
{% endhighlight %}
</div>

### break

Causes the loop to stop iterating when it encounters the `break` tag.

<p class="input">Input</p>
<div>
{% highlight liquid %}{% raw %}
  {% for i in (1..5) %}
    {% if i == 4 %}
      {% break %}
    {% else %}
      {{ i }}
    {% endif %}
  {% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight text %}
1 2 3
{% endhighlight %}
</div>

### continue

Causes the loop to skip the current iteration when it encounters the `continue` tag.

<p class="input">Input</p>
<div>
{% highlight liquid %}{% raw %}
  {% for i in (1..5) %}
    {% if i == 4 %}
      {% continue %}
    {% else %}
      {{ i }}
    {% endif %}
  {% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight text %}
1 2 3   5
{% endhighlight %}
</div>

<div class="sub-sub-section">

<h2 class="parameter">parameters <span>for</span></h2>

<h4>limit</h4>
Exits the for loop at a specific index.
<br/><br/>
<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
  <!-- if array = [1,2,3,4,5,6] -->
  {% for item in array limit:2 %}
    {{ item }}
  {% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
1 2
{% endraw %}{% endhighlight %}
</div>


<h4>offset</h4>
Starts the for loop at a specific index.
<br/><br/>
<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
  <!-- if array = [1,2,3,4,5,6] -->
  {% for item in array offset:2 %}
    {{ item }}
  {% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
3 4 5 6
{% endraw %}{% endhighlight %}
</div>

<h4>range</h4>
Defines a range of numbers to loop through. The range can be defined by both literal and variable numbers.
<br/><br/>
<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% assign num = 4 %}
{% for i in (1..num) %}
  {{ i }}
{% endfor %}

{% for i in (3..5) %}
  {{ i }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
1 2 3 4
3 4 5
{% endraw %}{% endhighlight %}
</div>


<h4>reversed
</h4>
Reverses the order of the for loop.
<br/><br/>
<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- if array = [1,2,3,4,5,6] -->
{% for item in array reversed %}
	{{ item }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
6 5 4 3 2 1
{% endraw %}{% endhighlight %}
</div>

</div>





















### cycle

Loops through a group of strings and outputs them in the order that they were passed as parameters. Each time <code>cycle</code> is called, the next string that was passed as a parameter is output.

<code>cycle</code> must be used within a <a href="#for">for</a> loop block.


<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% cycle 'one', 'two', 'three' %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
one
two
three
one
{% endraw %}{% endhighlight %}
</div>

Uses for <code>cycle</code> include:

- applying odd/even classes to rows in a table
- applying a unique class to the last product thumbnail in a row

<div class="sub-sub-section">

<h2 class="parameter">parameters <span>cycle</span></h2>


<code>cycle</code> accepts a parameter called <strong>cycle group</strong> in cases where you need multiple <code>cycle</code> blocks in one template. If no name is supplied for the cycle group, then it is assumed that multiple calls with the same parameters are one group.

<p>The example below shows why cycle groups are necessary when there are multiple instances of the cycle block.</p>

<div>
{% highlight html %}{% raw %}
<ul>
{% for product in collections.collection-1.products %}
  <li{% cycle ' style="clear:both;"', '', '', ' class="last"' %}>
    <a href="{{ product.url | within: collection }}">
      <img src="{{ product.featured_image.src | product_img_url: 'medium' }}" alt="{{ product.featured_image.alt }}" />
    </a>
  </li>
{% endfor %}
</ul>
<ul>
{% for product in collections.collection-2.products %}
  <li{% cycle ' style="clear:both;"', '', '', ' class="last"' %}>
    <a href="{{ product.url | within: collection }}">
      <img src="{{ product.featured_image.src | product_img_url: 'medium' }}" alt="{{ product.featured_image.alt }}" />
    </a>
  </li>
{% endfor %}
</ul>
{% endraw %}{% endhighlight %}
</div>

<p>In the code above, if the first collection only has two products, the second collection loop will continue the <code>cycle</code> where the first one left off. This will result in this undesired output:</p>

<div>
{% highlight html %}{% raw %}
<ul>
  <li style="clear:both"></li>
</ul>
<ul>
  <li></li>
  <li class="last"></li>
  <li style="clear:both"></li>
  <li></li>
</ul>
{% endraw %}{% endhighlight %}
</div>

<p>To avoid this, cycle groups are used for each <code>cycle</code> block, as shown below.</p>

<div>
{% highlight html %}{% raw %}
<ul>
{% for product in collections.collection-1.products %}
  <li{% cycle 'group1': ' style="clear:both;"', '', '', ' class="last"' %}>
    <a href="{{ product.url | within: collection }}">
      <img src="{{ product.featured_image.src | product_img_url: "medium" }}" alt="{{ product.featured_image.alt }}" />
    </a>
  </li>
{% endfor %}
</ul>
<ul>
{% for product in collections.collection-2.products %}
  <li{% cycle 'group2': ' style="clear:both;"', '', '', ' class="last"' %}>
    <a href="{{ product.url | within: collection }}">
      <img src="{{ product.featured_image.src | product_img_url: "medium" }}" alt="{{ product.featured_image.alt }}" />
    </a>
  </li>
{% endfor %}
</ul>
{% endraw %}{% endhighlight %}
</div>

<p>With the code above, the two <code>cycle</code> blocks are independent of each other. The result is shown below:</p>

<div>
{% highlight html %}{% raw %}
<ul>
  <li style="clear:both"></li>
  <li></li>
</ul>
<!-- new cycle group starts! -->
<ul>
  <li style="clear:both"></li>
  <li></li>
  <li></li>
  <li class="last"></li>
</ul>
{% endraw %}{% endhighlight %}
</div>

</div>









### tablerow

<p>Generates an HTML <code>&#60;table&#62;</code>. Must be wrapped in an opening &lt;table&gt; and closing &lt;/table&gt; HTML tags. For a full list of attributes available within a tablerow loop, see <a href="/themes/liquid-documentation/objects/tablerow">tablerow (object)</a>.</p>


<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
<table>
{% tablerow product in collection.products %}
  {{ product.title }}
{% endtablerow %}
</table>
{% endraw %}{% endhighlight %}
</div>


<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<table>
	<tr class="row1">
		<td class="col1">
			Cool Shirt
		</td>
		<td class="col2">
			Alien Poster
		</td>
		<td class="col3">
			Batman Poster
		</td>
		<td class="col4">
			Bullseye Shirt
		</td>
		<td class="col5">
			Another Classic Vinyl
		</td>
		<td class="col6">
			Awesome Jeans
		</td>
	</tr>
</table>
{% endraw %}{% endhighlight %}
</div>


<div class="sub-sub-section">

<h2 class="parameter">parameters <span>tablerow</span></h2>


<h4>cols</h4>

Defines how many columns the tables should have.
<br/><br/>
<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{% tablerow product in collection.products cols:2 %}
  {{ product.title }}
{% endtablerow %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<table>
	<tr class="row1">
		<td class="col1">
			Cool Shirt
		</td>
		<td class="col2">
			Alien Poster
		</td>
	</tr>
	<tr class="row2">
		<td class="col1">
			Batman Poster
		</td>
		<td class="col2">
			Bullseye Shirt
	  	</td>
	</tr>
	<tr class="row3">
		<td class="col1">
  		    Another Classic Vinyl
	  	</td>
		<td class="col2">
  		    Awesome Jeans
	  	</td>
	</tr>
</table>
{% endraw %}{% endhighlight %}
</div>

<h4>limit</h4>

Exits the tablerow after a specific index.
<br/><br/>
<div>
{% highlight html %}{% raw %}
{% tablerow product in collection.products cols:2 limit:3 %}
  {{ product.title }}
{% endtablerow %}
{% endraw %}{% endhighlight %}
</div>


<h4>offset</h4>

Starts the tablerow after a specific index.
<br/><br/>
<div>
{% highlight html %}{% raw %}
{% tablerow product in collection.products cols:2 offset:3 %}
  {{ product.title }}
{% endtablerow %}
{% endraw %}{% endhighlight %}
</div>


<h4>range</h4>

Defines a range of numbers to loop through. The range can be defined by both literal and variable numbers.
<br/><br/>


<div>
{% highlight html %}{% raw %}
<!--variable number example-->

{% assign num = 4 %}
<table>
{% tablerow i in (1..num) %}
  {{ i }}
{% endtablerow %}
</table>

<!--literal number example-->

<table>
{% tablerow i in (3..5) %}
  {{ i }}
{% endtablerow %}
</table>
{% endraw %}{% endhighlight %}
</div>

</div>


