---
layout: default
title: order

nav:
  group: Liquid Variables
---

# order

The <code>order</code> object can be accessed in order email templates, the Thank You page of the checkout, as well as in apps such as <a href="http://docs.shopify.com/manual/more/official-shopify-apps/order-printer">Order Printer</a>.

The <code>order</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}


{% anchor_link "order.billing_address", "order-billing_address" %}

Returns the billing <a href="/themes/liquid-documentation/objects/address/">address</a> of the order. 





{% anchor_link "order.cancelled", "order-cancelled" %}

<p>Returns <code>true</code> if an order is cancelled, returns <code>false</code>if it not.</p>








{% anchor_link "order.cancelled_at", "order-cancelled_at" %}

<p>Returns the timestamp of when an order was cancelled. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#date">date</a> filter to format the timestamp.</p>









{% anchor_link "order.cancel_reason", "order-cancel_reason" %}

<p>Returns the cancellation reason of an order, if it was cancelled.</p>








{% anchor_link "order.created_at", "order-created_at" %}

<p>Returns the timestamp of when an order was created. Use the <a href="/themes/liquid-documentation/filters/additional-filters/#date">date</a> filter to format the timestamp.</p>










{% anchor_link "order.customer", "order-customer" %}

<p>Returns the <a href="/themes/liquid-documentation/objects/customer/">customer</a> associated to the order.








{% anchor_link "order.customer_url", "order-customer_url" %}

<p>Returns the URL of the customer's account page.</p>

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{{ order.name | link_to: order.customer_url }}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
http://john-apparel.myshopify.com/account/orders/d94ec4a1956f423dc4907167c9ef0413
{% endraw %}{% endhighlight %}</div>









{% anchor_link "order.discounts", "order-discounts" %}

<p>Returns an array of <a href="/themes/liquid-documentation/objects/discount/">discounts</a> for an order.</p>

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{% for discount in order.discounts %}
    Code: {{ discount.code }}
    Savings: {{ discount.savings | money }}
{% endfor %}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
Code: SUMMER2014 
Savings: -€50
{% endraw %}{% endhighlight %}</div>










{% anchor_link "order.email", "order-email" %}

<p>Returns the email associated with an order.</p>








{% anchor_link "order.financial_status", "order-financial_status" %}

<p>Returns the financial status of an order. The possible values are:</p>

- pending
- authorized
- paid
- partially_paid
- refunded
- partially_refunded
- voided








{% anchor_link "order.fulfillment_status", "order-fulfillment_status" %}

<p>Returns the fulfillment status of an order.</p>








{% anchor_link "order.line_items", "order-line_items" %}

<p>Returns an array of <a href="/themes/liquid-documentation/objects/line_item/">line items</a> from the order.</p>









{% anchor_link "order.location", "order-location" %}

<p><strong>POS Only</strong>. Displays the physical location of the order. You can configure locations in the <a href="http://shopify.com/admin/settings/locations">Locations settings</a> of the admin.</p>









{% anchor_link "order.name", "order-name" %}

Returns the name of the order, in the format set in the <strong>Standards & formats</strong> section of the <a href="/admin/settings/general">General Settings</a>. 

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{{ order.name }}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
#1025
{% endraw %}{% endhighlight %}</div>









{% anchor_link "order.order_number", "order-order_number" %}

<p>Returns the integer representation of the order name.</p>

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{{ order.order_number }}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
1025
{% endraw %}{% endhighlight %}</div>









{% anchor_link "order.shipping_address", "order-shipping_address" %}

Returns the shipping <a href="/themes/liquid-documentation/objects/address/">address</a> of the order. 








{% anchor_link "order.shipping_methods", "order-shipping_methods" %}

Returns an array of  <a href="/themes/liquid-documentation/objects/shipping_method/">shipping_method</a> variables from the order. 







{% anchor_link "order.shipping_price", "order-shipping_price" %}

<p>Returns the shipping price of an order. Use a <a href="/themes/liquid-documentation/filters/money-filters/">money filter</a> to return the value in a monetary format.</p>








{% anchor_link "order.subtotal_price", "order-subtotal_price" %}

<p>Returns the subtotal price of an order. Use a <a href="/themes/liquid-documentation/filters/money-filters/">money filter</a> to return the value in a monetary format.</p>









{% anchor_link "order.tax_lines", "order-tax_lines" %}

<p>Returns an array of <a href="/themes/liquid-documentation/objects/tax_line/">tax_line</a> variables for an order.</p>

<p class="input">Input</p>
<div>{% highlight html %}{% raw %}
{% for tax_line in order.tax_lines %}
  Tax ({{ tax_line.title }} {{ tax_line.rate | times: 100 }}%):
  {{ tax_line.price | money }}
{% endfor %}
{% endraw %}{% endhighlight %}</div>

<p class="output">Output</p>
<div>{% highlight html %}{% raw %}
Tax (GST 14.0%): $25
{% endraw %}{% endhighlight %}</div>









{% anchor_link "order.tax_price", "order-tax_price" %}

<p>Returns the order's tax price.  Use a <a href="/themes/liquid-documentation/filters/money-filters/">money filter</a> to return the value in a monetary format.</p>











{% anchor_link "order.total_price", "order-total_price" %}

<p>Returns the total price of an order.  Use a <a href="/themes/liquid-documentation/filters/money-filters/">money filter</a> to return the value in a monetary format.</p>










{% anchor_link "order.transactions", "order-transactions" %}

<p>Returns an array of <a href="/themes/liquid-documentation/objects/transaction/">transactions</a> from the order.</p>








