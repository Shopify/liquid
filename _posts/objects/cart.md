---
layout: default
title: cart

nav:
  group: Liquid Variables
---

# cart

The  <code>cart</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}



{% anchor_link "cart.attributes", "cart-attributes" %}

<code>cart.attributes</code> allow the capturing of more information on the cart page. This is done by giving an input a <code>name</code>attribute with the following syntax:

<div>
{% highlight html %}{% raw %}
attributes[attribute-name]
{% endraw %}{% endhighlight %}
</div>

Shown below is a basic example of how to use an HTML input of type "text" to capture  information on the cart page. 

<div>
{% highlight html %}{% raw %}
<label>What is your Pet's name?</label>
<input type="text" name="attributes[your-pet-name]" value="{{ cart.attributes.your-pet-name }}" />
{% endraw %}{% endhighlight %}
</div>

<code>cart.attributes</code> can be accessed in order email templates, the Thank You page of the checkout, as well as in apps such as <a href="http://docs.shopify.com/manual/more/official-shopify-apps/order-printer">Order Printer</a>. 

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ attributes.your-pet-name }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Haku
{% endraw %}{% endhighlight %}
</div>

For more examples on how to use cart attributes, see <a href="http://docs.shopify.com/manual/configuration/store-customization/communicating-with-customers/obtain-information/ask-customer-for-more-information#cart-attributes">Ask a customer for additional information</a>. 







{% anchor_link "cart.item_count", "cart-item_count" %}

 <p>Returns the number of items inside the cart.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ cart.item_count }} {{ cart.item_count | pluralize: 'Item', 'Items' }} ({{ cart.total_price | money }})
{% endraw %}{% endhighlight %}
 </div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
25 Items ($53.00)
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "cart.items", "cart-items" %}

<p>Returns all of the <a href="/themes/liquid-documentation/objects/line_item/">line items</a> in the cart.</p>






{% anchor_link "cart.note", "cart-note" %}

<code>cart.note</code> allows the capturing of more information on the cart page. 

This is done by submitting the cart form with an HTML <code>textarea</code> and wrapping the <code>cart.note</code> output.  

<div>
{% highlight html %}{% raw %}
<label>Gift note:</label>
<textarea rows="100" cols="20">{{ cart.note }}</textarea>
{% endraw %}{% endhighlight %}
</div>

{% block "note" %}
There can only be one instance of <code>{% raw %}{{ cart.note }}{% endraw %}</code> on the cart page. If there are multiple instances, the one that comes latest in the Document Object Model (DOM) will be submitted with the form. 
{% endblock %}

<code>cart.note</code> can be accessed in order email templates, the Thank You page of the checkout, as well as in apps such as <a href="http://docs.shopify.com/manual/more/official-shopify-apps/order-printer">Order Printer</a>.  For examples on how to use cart notes, see  <a href="http://docs.shopify.com/manual/configuration/store-customization/communicating-with-customers/obtain-information/ask-customer-for-more-information#cart-note">Ask a customer for additional information</a>. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ note }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Hope you like the gift, Kylea! 
{% endraw %}{% endhighlight %}
</div>




{% anchor_link "cart.total_price", "cart-total_price" %}

<p>Returns the total price of all of the items in the cart.</p>







{% anchor_link "cart.total_weight", "cart-total_weight" %}

<p>Returns the total weight of all of the items in the cart.</p>




