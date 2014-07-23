---
layout: default
title: Money Filters
nav:
  group: Filters
  weight: '4'
---

# Money Filters

Money filters format prices based on the **Currency Formatting** found in <a href="http://www.shopify.com/admin/settings/general">General Settings</a>.

{{ '/themes/money_format_settings.jpg' | image }}

{% table_of_contents %}




{% anchor_link "money", "money" %}

<p>Formats the price based on the shop's <strong>HTML without currency</strong> setting.</p>  

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 145 | money }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html%}{% raw %}
<!-- if "HTML without currency" is ${{ amount }} -->
$1.45
<!-- if "HTML without currency" is €{{ amount_no_decimals }} -->
€1
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "money_with_currency", "money_with_currency" %}

<p>Formats the price based on the shop's <strong>HTML with currency</strong> setting.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 1.45 | money_with_currency }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<!-- if "HTML with currency" is ${{ amount }} CAD -->
$1.45 CAD
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "money_without_currency", "money_without_currency" %}


<p>Formats the price using a decimal.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 145 | money_without_currency }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
1.45
{% endraw %}{% endhighlight %}
</div>



