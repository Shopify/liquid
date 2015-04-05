---
title: default
---

`default` offers a means of having a fall-back value in case your value doesn't exist.

{% highlight liquid %}
{% raw %}
{{ product_price | default:2.99 }}
// => outputs "2.99"

{% assign product_price = 4.99 %}
{{ product_price | default:2.99 }}
// => outputs "4.99"

{% assign product_price = "" %}
{{ product_price | default:2.99 }}
// => outputs "2.99"
{% endraw %}
{% endhighlight %}

`default` will use its substitute if the left side is `nil`, `false`, or empty.
