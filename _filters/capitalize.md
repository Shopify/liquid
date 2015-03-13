---
title: capitalize
---

`capitalize` ensures the first character of your string is capitalized.

{% highlight liquid %}
{% raw %}
{{ "title" | capitalize }}
{% endraw %}
# => "Title"
{% endhighlight %}

It only capitalizes the first character, so subsequent words will not be capitalized as well.
