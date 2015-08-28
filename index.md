---
layout: default
---

{% include home-banner.html %}

  <p>Liquid is an extraction from the e-commerce system Shopify. Shopify powers many thousands of e-commerce stores which all call for unique designs. For this we developed Liquid which allows our customers complete design freedom while maintaining the integrity of our servers.</p>

  <p>Liquid has been in production use since June 2006 and is now used by many other hosted web applications.</p>

  <p>It was developed for usage in Ruby on Rails web applications and integrates seamlessly as a plugin but it also works excellently as a stand alone library.</p>

Liquid is an open-source, Ruby-based template language created by Shopify. It is the backbone of Shopify themes and is used to load dynamic content on storefronts.

Liquid uses a combination of _tags_, _objects_, and _filters_ to load dynamic content. They are used inside Liquid _template files_, which are a group of files that make up a theme. For more information on the available templates, please see <a href="/themes/theme-development/templates/">Theme Development</a>.

## Tags

Tags make up the programming logic that tells templates what to do.

{% raw %}
{% if user.name == 'elvis' %}
  Hey Elvis
{% endif %}
{% endraw %}


## Filters

Filters are used to modify the output of strings, numbers, variables, and objects.

{% raw %}
{{ 'sales' | append: '.jpg' }} <!-- Output: sales.jpg -->
{% endraw %}
