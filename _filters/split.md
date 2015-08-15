---
title: split
---

The `split` filter takes on a substring as a parameter. The substring is used as a delimiter to divide a string into an array. You can output different parts of an array using [array filters](/themes/liquid-documentation/filters/array-filters).

<p class="input">Input</p>
{% highlight liquid %}{% raw %}
{% assign words = "Hi, how are you today?" | split: ' ' %}

{% for word in words %}
{{ word }}
{% endfor %}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
{% highlight text %}
Hi,
how
are
you
today?
{% endhighlight %}
