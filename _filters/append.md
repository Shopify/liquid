---
title: append
---

`append` concatenates two strings and returns the concatenated value.

{% highlight liquid %}
{% raw %}
{{ "/my/fancy/url" | append:".html" }}
{% endraw %}
# => "/my/fancy/url.html"
{% endhighlight %}

It can also be used with variables:

{% highlight liquid %}
{% raw %}
{% assign filename = "/index.html" %}
{{ product.url | append:filename }}
{% endraw %}
# => "#{product.url}/index.html"
{% endhighlight %}
