---
layout: default
title: transaction

nav:
  group: Liquid Variables
---

# transaction

The  <code>transaction</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}


{% anchor_link "transaction.id", "transaction-id" %}

Returns the id of the transaction. 







{% anchor_link "transaction.amount", "transaction-amount" %}

Returns the amount of the transaction. Use one of the <a href="/themes/liquid-documentation/filters/money-filters/">money filters</a> to return the value in a monetary format.







{% anchor_link "transaction.name", "transaction-name" %}

Returns the name of the transaction.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ transaction.name }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
c251556901.1
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "transaction.status", "transaction-status" %}

Returns the status of the transaction. 










{% anchor_link "transaction.created_at", "transaction-created_at" %}

<p>Returns the timestamp of when the transaction was created. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#date">date</a> filter to format the timestamp.</p>















{% anchor_link "transaction.gateway", "transaction-gateway" %}

Returns the name of the payment gateway used for the transaction.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ transaction.gateway }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Cash on Delivery (COD)
{% endraw %}{% endhighlight %}
</div>












{% comment %} not including 'kind' and 'receipt' for now. No info can be found on these {% endcomment %}