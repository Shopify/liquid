---
layout: default
title: customer

nav:
  group: Liquid Variables
---

# customers

<p>The <code>customer</code> object contains information of customers who have created a <a href="http://docs.shopify.com/manual/your-store/customers/customer-accounts">Customer Account</a>.</p>

<p><code>customer</code> can also be accessed in order email templates, the Thank You page of the checkout, as well as in apps such as <a href="http://docs.shopify.com/manual/more/official-shopify-apps/order-printer">Order Printer</a>.</p>

<a id="topofpage"></a>

{% table_of_contents %}




{% anchor_link "customer.accepts_marketing", "customer-accepts_marketing" %}

<p>Returns <code>true</code> if the customer accepts marketing, returns <code>false</code> if the customer does not.</p>








{% anchor_link "customer.addresses", "customer-addresses" %}

Returns an array of all of the customer addresses associated with a customer. See <a href="/themes/liquid-documentation/objects/customer-address/">customer_address</a> for a full list of available attributes. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for address in customer.addresses %}
  {{ address.street }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
126 York St, Suite 200 (Shopify Office)
123 Fake St
53 Featherston Lane
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "customer.addresses_count", "customer-addresses_count" %}

<p>Returns the number of addresses associated with a customer.</p>








{% anchor_link "customer.default_address", "customer-default_address" %}

<p>Returns the default <a href="/themes/liquid-documentation/objects/customer-address/">customer_address</a> of a customer.</p>








{% anchor_link "customer.email", "customer-email" %}

<p>Returns the email address of the customer.</p>









{% anchor_link "customer.first_name", "customer-first_name" %}

<p>Returns the first name of the customer.</p>








{% anchor_link "customer.id", "customer-id" %}

<p>Returns the id of the customer.</p>










{% anchor_link "customer.last_name", "customer-last_name" %}

<p>Returns the last name of the customer.</p>










{% anchor_link "customer.last_order", "customer-last_order" %}

<p>Returns the last <a href="/themes/liquid-documentation/objects/order/">order </a> placed by the customer. </p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
Your last order was placed on: {{ customer.last_order.created_at | date: "%B %d, %Y %I:%M%p" }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Your last order was placed on: April 25, 2014 01:49PM
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "customer.name", "customer-name" %}

<p>Returns the full name of the customer.</p>









{% anchor_link "customer.orders", "customer-orders" %}

<p>Returns an array of all <a href="/themes/liquid-documentation/objects/order/">orders</a> placed by the customer.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for order in customer.orders %}
{{ order.id }}
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
#1088
#1089
#1090
{% endraw %}{% endhighlight %}
</div>










{% anchor_link "customer.orders_count", "customer-orders_count" %}

<p>Returns the total number of orders a customer has placed.</p>








{% anchor_link "customer.recent_order", "customer-recent_order" %}

<p>Returns the most recent <a href="/themes/liquid-documentation/objects/order/">order </a> placed by the customer. </p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
Your most recent order was placed on: {{ customer.recent_order.created_at | date: "%B %d, %Y %I:%M%p" }} 
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Your last order was placed on: August 25, 2014 05:49PM
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "customer.tags", "customer-tags" %}

Returns the list of tags associated with the customer.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% for tag in customer.tags %}
{{ tag }} 
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
wholesale regular-customer VIP 
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "customer.total_spent", "customer-total_spent" %}

<p>Returns the total amount spent on all orders.</p>




