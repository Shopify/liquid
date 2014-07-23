---
layout: default
title: address

nav:
  group: Liquid Variables
---

# address

The <code>address</code> object contains information entered by a customer in Shopify's checkout pages.  Note that a customer can enter two addresses: **billing address** or **shipping address**. 

{{ '/themes/address.jpg' | image }}

When accessing attributes of the <code>address</code> object, you must specify which address you want to target. This is done by using either <code>shipping_address</code> or <code>billing_address</code> before the attribute. 

<code>address</code> can be used in email templates, the Thank You page of the checkout, as well as in apps such as Order Printer. 

{% table_of_contents %}




{% anchor_link "address.name", "address-name" %}

Returns the values of the First Name **and** Last Name fields of the address. 

<p class="input">Input</p>

{% highlight html %}{% raw %}
Hello, {{ billing_address.name }} 
{% endraw %}{% endhighlight %}

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Hello, Bob Biller
{% endraw %}{% endhighlight %}
</div>





{% anchor_link "address.first_name", "address-first_name" %}

Returns the value of the First Name field of the address.




{% anchor_link "address.last_name", "address-last_name" %}

Returns the value of the Last Name field of the address.






{% anchor_link "address.address1", "address-address1" %}

Returns the value of the Address1 field of the address.




{% anchor_link "address.address2", "address-address2" %}

Returns the value of the Address2 field of the address.




{% anchor_link "address.street", "address-street" %}

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






{% anchor_link "address.company", "address-company" %}

Returns the value of the Company field of the address.





{% anchor_link "address.city", "address-city" %}

Returns the value of the City field of the address.





{% anchor_link "address.province", "address-province" %}

Returns the value of the Province/State field of the address.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ billing_address.province }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Ontario
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "address.province_code", "address-province_code" %}

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





{% anchor_link "address.zip", "address-zip" %}


Returns the value of the Postal/Zip field of the address.





{% anchor_link "address.country", "address-country" %}

Returns the value of the Country field of the address.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ shipping_address.country }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Canada
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "address.country_code", "address-country_code" %}

Returns the value of the Country field of the address in ISO 3166-2 standard format.

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ shipping_address.country_code }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
CA
{% endraw %}{% endhighlight %}
</div>




{% anchor_link "address.phone", "address-phone" %}

Returns the value of the Phone field of the address.


