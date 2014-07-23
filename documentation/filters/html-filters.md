---
layout: default
title: HTML Filters
nav:
  group: Filters
  weight: 4
---

#HTML Filters

HTML filters wrap assets in HTML tags. 

{% table_of_contents %}




{% anchor_link "img_tag", "img_tag" %}

<p>Generates an image tag.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'smirking_gnome.gif' | asset_url | img_tag }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<img src="//cdn.shopify.com/s/files/1/0147/8382/t/15/assets/smirking_gnome.gif?v=1384022871" alt="" />
{% endraw %}{% endhighlight %}
</div>

<code>img_tag</code> accepts parameters to output an alt tag and class names.  The first parameter is output as the alt text, and any other following parameters are output as CSS classes.

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'smirking_gnome.gif' | asset_url | img_tag: 'Smirking Gnome', 'cssclass1 cssclass2' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<img src="//cdn.shopify.com/s/files/1/0147/8382/t/15/assets/smirking_gnome.gif?v=1384022871" alt="Smirking Gnome" class="cssclass1 cssclass2" />
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "script_tag", "script_tag" %}

<p>Generates a script tag.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'shop.js' | asset_url | script_tag }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<script src="//cdn.shopify.com/s/files/1/0087/0462/t/394/assets/shop.js?28178" type="text/javascript"></script>
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "stylesheet_tag", "stylesheet_tag" %}

<p>Generates a stylesheet tag.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ 'shop.css' | asset_url | stylesheet_tag }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<link href="//cdn.shopify.com/s/files/1/0087/0462/t/394/assets/shop.css?28178" rel="stylesheet" type="text/css" media="all" />


{% endraw %}{% endhighlight %}
</div>




