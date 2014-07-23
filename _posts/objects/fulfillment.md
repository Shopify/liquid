---
layout: default
title: fulfillment

nav:
  group: Liquid Variables
---

# fulfillment

The <code>fulfillment</code> object has the following attributes:

<a id="topofpage"></a>
{% table_of_contents %}



{% comment %} Commenting out as this doesn't actually work. 

{% anchor_link "fulfillment.created_at", "fulfillment.created_at" %}

<p>Returns the date the fulfillment was created at.</p>

<div>
{% highlight html %}{% raw %}
Fulfilled {{ line_item.fulfillment.created_at | date: "%b %d" }}
{% endraw %}{% endhighlight %}
</div>



{% endcomment %}





{% anchor_link "fulfillment.tracking_company", "fulfillment-tracking_company" %}

<p>Returns the name of the fulfillment service.</p>








{% anchor_link "fulfillment.tracking_number", "fulfillment-tracking_number" %}

<p>Returns the tracking number for a fulfillment if it exists.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
Tracking Number: {{ line_item.fulfillment.tracking_number }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Tracking Number: 1Z5F44813600X02768
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "fulfillment.tracking_url", "fulfillment-tracking_url" %}

<p>Returns the URL for a tracking number.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ fulfillment.tracking_url }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
http://wwwapps.ups.com/etracking/tracking.cgi?InquiryNumber1=1Z5F44813600X02768&TypeOfInquiryNumber=T&AcceptUPSLicenseAgreement=yes&submit=Track
{% endraw %}{% endhighlight %}
</div>




