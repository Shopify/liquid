---
layout: default
title: Additional Filters
nav:
  group: Filters
  weight: 10
---

# Additional Filters

General filters serve many different purposes including formatting, converting, and applying CSS classes.


{% table_of_contents %}



{% anchor_link "date", "date" %}

<p>Converts a timestamp into another date format.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%a, %b %d, %y" }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Tue, Apr 22, 14
{% endraw %}{% endhighlight %}
</div>

<p>The date parameters are listed below:</p>

<table class="filter-date-table">
	<tbody>
		<tr>
			<td><pre>%a</pre></td>
			<td><p>Abbreviated weekday.</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%a" }}
<!-- Sat -->
{% endraw %}{% endhighlight %}
</div>
			</td>
		</tr>
		<tr>
			<td><pre>%A</pre></td>
			<td><p>Full weekday name.</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%A" }}
<!-- Tuesday -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%b</pre></td>
			<td><p>Abbreviated month name.</p> 
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%b" }}
<!-- Jan -->
{% endraw %}{% endhighlight %}
</div>
			</td>
		</tr>
		<tr>
			<td><pre>%B</pre></td>
			<td><p>Full month name</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%B" }}
<!-- January -->
{% endraw %}{% endhighlight %}
</div>


</td>
		</tr>
		<tr>
			<td><pre>%c</pre></td>
			<td><p>Preferred local date and time representation</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%c" }}
<!-- Tue Apr 22 11:16:09 2014 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%d</pre></td>
			<td><p>Day of the month, zero-padded (01, 02, 03, etc.).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%d" }}
<!-- 04 -->
{% endraw %}{% endhighlight %}
</div>

</td>
		</tr>
		<tr>
			<td><pre>%-d</pre></td>
			<td><p>Day of the month, not zero-padded (1,2,3, etc.).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%-d" }}
<!-- 4 -->
{% endraw %}{% endhighlight %}
</div>


</td>
		</tr>
	<tr>
			<td><pre>%D</pre></td>
			<td><p>Formats the date (dd/mm/yy).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%D" }}
<!-- 04/22/14 -->
{% endraw %}{% endhighlight %}
</div>


</td>
		</tr>
		<tr>
			<td><pre>%e</pre></td>
			<td>
				<p>Day of the month, blank-padded ( 1, 2, 3, etc.).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%e" }}
<!-- 3 -->
{% endraw %}{% endhighlight %}
</div>
			</td>
		</tr>

	<tr>
			<td><pre>%F</pre></td>
			<td>
				<p>Returns the date in ISO 8601 format (yyyy-mm-dd).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%F" }}
<!-- 2014-04-22 -->
{% endraw %}{% endhighlight %}
</div>
			</td>
		</tr>


		<tr>
			<td><pre>%H</pre></td>
			<td><p>Hour of the day, 24-hour clock (00 - 23).</p>
	<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%H" }}
<!-- 15 -->
{% endraw %}{% endhighlight %}
</div>

</td>
		</tr>
		<tr>
			<td><pre>%I</pre></td>
			<td><p>Hour of the day, 12-hour clock (1 - 12).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%I" }}
<!-- 7 -->
{% endraw %}{% endhighlight %}
</div>

</td>
		</tr>
		<tr>
			<td><pre>%j</pre></td>
			<td><p>Day of the year (001 - 366).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%j" }}
<!-- 245 -->
{% endraw %}{% endhighlight %}
</div>

</td>

		</tr>
		<tr>
			<td><pre>%k</pre></td>
			<td><p>Hour of the day, 24-hour clock (1 - 24).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%k" }}
<!-- 14 --> 
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%m</pre></td>
			<td><p>Month of the year (01 - 12).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%m" }}
<!-- 04 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%M</pre></td>
			<td><p>Minute of the hour (00 - 59).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%M" }}
<!--53-->
{% endraw %}{% endhighlight %}
</div>

</td>
		</tr>
		<tr>
			<td><pre>%p</pre></td>
			<td><p>Meridian indicator (AM/PM).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%p" }}
<!-- PM -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>

	<tr>
			<td><pre>%r</pre></td>
			<td><p>12-hour time (%I:%M:%S %p)</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%r" }}
<!-- 03:20:07 PM -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>


	<tr>
			<td><pre>%r</pre></td>
			<td><p>12-hour time (%I:%M:%S %p)</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%r" }}
<!-- 03:20:07 PM -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>


		<tr>
			<td><pre>%R</pre></td>
			<td><p>24-hour time (%H:%M)</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%R" }}
<!-- 15:21 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>

	<tr>
			<td><pre>%T</pre></td>
			<td><p>24-hour time (%H:%M:%S)</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%T" }}
<!-- 15:22:13 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>

		<tr>
			<td><pre>%U</pre></td>
			<td>The number of the week in the current year, starting with the first Sunday as the first day of the first week.
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%U" }}
<!-- 16 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%W</pre></td>
			<td><p>The number of the week in the current year, starting with the first Monday as the first day of the first week.</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%W" }}
<!-- 16 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%w</pre></td>
			<td><p>Day of the week (0 - 6, with Sunday being 0).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%w" }}
<!-- 2 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%x</pre></td>
			<td><p>Preferred representation for the date alone, no time. (mm/dd/yy).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%x" }}
<!-- 04/22/14 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%X</pre></td>
			<td><p>Preferred representation for the time. (hh:mm:ss). </p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%X" }}
<!-- 13:17:24 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%y</pre></td>
			<td><p>Year without a century (00.99).</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%y" }}
<!-- 14 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%Y</pre></td>
			<td><p>Year with a century.</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%Y" }}
<!-- 2014 -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		<tr>
			<td><pre>%Z</pre></td>
			<td><p>Time zone name.</p>
<div>
{% highlight html %}{% raw %}
{{ article.published_at | date: "%Z" }}
<!-- EDT -->
{% endraw %}{% endhighlight %}
</div>
</td>
		</tr>
		</tbody>
</table>







{% anchor_link "default", "default" %}

Sets a default value for any variable with no assigned value. Can be used with strings, arrays, and hashes. 

<p class="input">Input</p>
{% highlight html %}{% raw %}
Dear {{ customer.name | default: "customer" }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<!-- if customer.name is nil -->
Dear customer 
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "default_errors", "default_errors" %}

Outputs default error messages for the <a href="/themes/liquid-documentation/objects/form/#form.errors">form.errors</a> variable. The messages returned are dependent on the strings returned by <code>form.errors</code>. 

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
<!-- if form.errors returned "email" -->
Please enter a valid email address.
{% endraw %}{% endhighlight %}
</div>













{% anchor_link "default_pagination", "default_pagination" %}


Creates a set of links for paginated results. Used in conjunction with the <a href="/themes/liquid-documentation/objects/paginate/">paginate</a> variable.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ paginate | default_pagination }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<span class="page current">1</span>
<span class="page"><a href="/collections/all?page=2" title="">2</a></span>
<span class="page"><a href="/collections/all?page=3" title="">3</a></span> 
<span class="deco">&hellip;</span>
<span class="page"><a href="/collections/all?page=17" title="">17</a></span>
<span class="next"><a href="/collections/all?page=2" title="">Next &raquo;</a></span>
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "highlight", "highlight" %}

Wraps words inside search results with an HTML <code>&#60;strong&#62;</code> tag with the class <code>highlight</code> if it matches the submitted <a href="/themes/liquid-documentation/objects/search/#search.terms">search.terms</a>. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ item.content | highlight: search.terms }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<!-- If the search term was "Yellow" -->
<strong class="highlight">Yellow</strong> shirts are the best! 
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "highlight_active_tag", "highlight_active_tag" %}

<p>Wraps a tag link in a <code>&#60;span&#62;</code> with the class <code>active</code> if that tag is being used to filter a collection.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- collection.tags = ["Cotton", "Crew Neck", "Jersey"] -->
{% for tag in collection.tags %}
	{{ tag | highlight_active | link_to_tag: tag }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<a title="Show products matching tag Cotton" href="/collections/all/cotton"><span class="active">Cotton</span></a>
<a title="Show products matching tag Crew Neck" href="/collections/all/crew-neck">Crew Neck</a>
<a title="Show products matching tag Jersey" href="/collections/all/jersey">Jersey</a>
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "json", "json" %}

Converts a string into JSON format.  

<p class="input">Input</p>

{% highlight html%}{% raw %}
var content = {{ pages.page-handle.content | json }};
{% endraw %}{% endhighlight %}

<p class="output">Output</p> 

<div>
{% highlight html %}{% raw %}
var content = "\u003Cp\u003E\u003Cstrong\u003EYou made it! Congratulations on starting your own e-commerce store!\u003C/strong\u003E\u003C/p\u003E\n\u003Cp\u003EThis is your shop\u0026#8217;s \u003Cstrong\u003Efrontpage\u003C/strong\u003E, and it\u0026#8217;s the first thing your customers will see when they arrive. You\u0026#8217;ll be able to organize and style this page however you like.\u003C/p\u003E\n\u003Cp\u003E\u003Cstrong\u003ETo get started adding products to your shop, head over to the \u003Ca href=\"/admin\"\u003EAdmin Area\u003C/a\u003E.\u003C/strong\u003E\u003C/p\u003E\n\u003Cp\u003EEnjoy the software,  \u003Cbr /\u003E\nYour Shopify Team.\u003C/p\u003E";
{% endraw %}{% endhighlight %}
</div>

{% block "note-information" %}
<p>You do not have to wrap the Liquid output in quotations - the <code>json</code> filter will add them in. The <code>json</code> filter will also escape quotes as needed inside the output.</p>
{% endblock %}

<p>The <code>json</code> filter can also used to make Liquid objects readable by JavaScript:</p>

{% highlight html%}{% raw %}
var json_product = {{ collections.featured.products.first | json }};
var json_cart = {{ cart | json }};
{% endraw %}{% endhighlight %}











{% anchor_link "weight_with_unit", "weight_with_unit" %}

<p>Formats the product variant's weight. The weight unit is set in <a href="http://www.shopify.com/admin/settings/general">General Settings</a>.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ product.variants.first.weight | weight_with_unit }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
24.0 kg
{% endraw %}{% endhighlight %}
</div>









