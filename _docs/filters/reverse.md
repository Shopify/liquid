---
title: reverse
---

Reverses the order of an array.

{% highlight liquid %}
{% raw %}
{{ product.tags }}
// ['cool', 'sale', 'purple', 'awesome']

{{ product.tags | reverse }}
// ['awesome', 'purple', 'sale', 'cool']
{% endraw %}
{% endhighlight %}
