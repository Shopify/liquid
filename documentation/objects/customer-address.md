---
layout: default
title: customer_address

nav:
  group: Liquid Variables
---

# customer_address

The <code>customer_address</code> contains information of addresses tied to a <a href="http://docs.shopify.com/manual/your-store/customers/customer-accounts">Customer Account</a>. 

{% table_of_contents %}





{% anchor_link "customer_address.first_name", "first-name" %}

Returns the value of the First Name field of the address.








{% anchor_link "customer_address.last_name", "last-name" %}

Returns the value of the Last Name field of the address.















{% anchor_link "customer_address.address1", "customer_address-address1" %}

Returns the value of the Address1 field of the address.








{% anchor_link "customer_address.address2", "customer_address-address2" %}

Returns the value of the Address2 field of the address.










{% anchor_link "customer_address.street", "street" %}

Returns the combined values of the Address1 and Address2 fields of the address.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ shipping_address.street }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
126 York St, Shopify Office
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "customer_address.company", "company" %}

Returns the value of the Company field of the address.










{% anchor_link "customer_address.city", "city" %}

Returns the value of the City field of the address.








{% anchor_link "customer_address.province", "province" %}

Returns the value of the Province/State field of the address.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ customer_address.province }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Ontario
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "customer_address.province_code", "province_code" %}

Returns the abbreviated value of the Province/State field of the address.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ billing_address.province_code }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
ON
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "customer_address.zip", "zip" %}

Returns the value of the Postal/Zip field of the address.









{% anchor_link "customer_address.country", "country" %}

Returns the value of the Country field of the address.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ customer_address.country }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Japan
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "customer_address.country_code", "country-code" %}

Returns the value of the Country field of the address in ISO 3166-2 standard format.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ customer_address.country_code }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
CA
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "customer_address.phone", "phone" %}

Returns the value of the Phone field of the address.





{% anchor_link "customer_address.id", "id" %}

Returns the id of customer address. 