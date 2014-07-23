---
layout: default
title: country_option_tags

nav:
  group: Liquid Variables
---

# country_option_tags

<code>country_option_tags</code> creates an &#60;option&#62; tag for each country. An attribute named <code>data-provinces</code> is set for each country, containing JSON-encoded arrays of the country's respective subregions. If a country does not have any subregions, an empty array is set for its <code>data-provinces</code> attribute.

<code>country_option_tags</code> must be wrapped in &#60;select&#62; HTML tags.


<p class="input">Input</p>

{% highlight html %}{% raw %}
<select name="country">
  {{ country_option_tags }}
</select>
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

{% highlight html %}
<select name="country">
  <option value"" data-provinces="[]">- Please Select --</option>
  ...
  ...
  <option value="Canada" data-provinces="["Alberta","British Columbia","Manitoba","New Brunswick","Newfoundland","Northwest Territories","Nova Scotia","Nunavut","Ontario","Prince Edward Island","Quebec","Saskatchewan","Yukon"]">Canada</option>
  <option value="China" data-provinces="[]">China</option>
  ...
  ...
</select>
{% endhighlight %}

