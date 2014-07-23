---
layout: default
title: gift_card

nav:
  group: Liquid Variables
---

# gift_card

The <code>gift_card</code> object can be accessed in the following templates:

1. The Gift Card Notification email notification template [Email Notifications > Gift Card Notification](http://shopify.com/admin/settings/notifications)

2. The [**gift_card.liquid**](/themes/theme-development/templates/gift-cards-liquid/) template.

The <code>gift_card</code> variable has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}




{% anchor_link "gift_card.balance", "gift_card-balance" %}

<p>Returns the amount of money remaining on the gift card.</p>










{% anchor_link "gift_card.code", "gift_card-code" %}

<p>Returns the code that was used to redeem the gift card.</p>










{% anchor_link "gift_card.currency", "gift_card-currency" %}

<p>Returns the currency that the card was issued in.</p>









{% anchor_link "gift_card.customer", "gift_card-customer" %}

Returns the <a href="/themes/liquid-documentation/objects/customer/">customer</a> variable of the customer that the gift card is assigned to. 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
Hey, {{ gift_card.customer.first_name }}!
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Hey, John! 
{% endraw %}{% endhighlight %}
</div>













{% anchor_link "gift_card.enabled", "gift_card-enabled" %}

<p>Returns <code>true</code> if the card is enabled, or <code>false</code> if the card is disabled.</p>









{% anchor_link "gift_card.expired", "gift_card-expired" %}

<p>Returns <code>true</code> if the card is expired, or <code>false</code> if the card is not.</p>












{% anchor_link "gift_card.expires_on", "gift_card-expires_on" %}

<p>Returns the expiration date of the gift card</p>










{% anchor_link "gift_card.initial_value", "gift_card-initial_value" %}

<p>Returns the initial amount of money on the gift card.</p>









{% anchor_link "gift_card.properties", "gift_card-properties" %}

<p>Returns the <a href="http://docs.shopify.com/support/your-store/products/how-do-I-collect-additional-information-on-the-product-page-Like-for-a-monogram-engraving-or-customization">line item properties</a> assigned to the gift card when it was added to the cart.</p>








{% anchor_link "gift_card.url", "gift_card-url" %}

<p>Returns the unique URL that links to the gift card's page on the shop (rendered through <strong>gift_card.liquid</strong>).</p>




