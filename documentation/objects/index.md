---
layout: default
title: Objects
landing_as_article: true

nav:
  group: Liquid Documentation
  weight: 2
---

# Objects

Liquid objects contain attributes to output dynamic content on the page. For example, the <code>product</code> object contains an attribute called <code>title</code> that can be used to output the title of a product.

**Liquid objects** are also often refered to as **Liquid variables**.

To output an object's attribute on the page, wrap them in  <code>&#123;&#123;</code> and  <code>&#125;&#125;</code>, as shown below: 

{% highlight html %}{% raw %}
{{ product.title }} <!-- Output: “Awesome Shoes” -->
{% endraw %}{% endhighlight %}


<h2 id='global-objects'>Global Objects</h2>

The following objects can be used and accessed from **any file** in your theme, and are defined as **global objects**, or global variables:

<table>
  <tbody>
    <tr>
      <td><pre>blogs</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
<ul>
  {% for article in blogs.myblog.articles  %}
   <li>{{ article.title | link_to: article.url }}</li>
  {% endfor %}
</ul>
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>blogs</code> refers to the blogs in your shop. <a href="/themes/liquid-documentation/objects/blog">More info &rsaquo;</a>
      </td>
    </tr>
    <tr>
      <td><pre>cart</pre></td>
      <td>
        <div></div>
        <p>The liquid object <code>cart</code> refers to the cart in your shop. <a href="/themes/liquid-documentation/objects/cart">More info &rsaquo;</a>
      </td>
    </tr>
    <tr>
      <td><pre>collections</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
{% for product in collections.frontpage.products %}
  {{ product.title }}
{% endfor %}
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>collections</code> contains a list of all of the collections in a shop. <a href="/themes/liquid-documentation/objects/collection">More info &rsaquo;</a></p>
      </td>
    </tr>
   <tr>
      <td><pre>current_page</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
{% if current_page != 1 %} Page {{ current_page }}{% endif %}
{% endraw %}{% endhighlight %}
        </div>
        <p>The <code>current_page</code> object returns the number of the page you are on when browsing through paginated content. <a href="/themes/liquid-documentation/objects/current-page">More info &rsaquo;</a></p>
      </td>
    </tr>
   <tr>
      <td><pre>current_tags</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
<!-- in blog.liquid -->
{% if current_tags %}
  <h1>{{ blog.title | link_to: blog.url }} &rsaquo; {{ current_tags.first }}</h1>
{% else %}
  <h1>{{ blog.title }}</h1>
{% endif %}
{% endraw %}{% endhighlight %}
        </div>
        <p>The <code>current_tags</code> object will contain a different list of tags depending on the type of template that is rendered. <a href="/themes/liquid-documentation/objects/current-tags">More info &rsaquo;</a>
      </td>
    </tr>
   <tr>
      <td><pre>customer</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
{% if shop.customer_accounts_enabled %}
  {% if customer %}
    <a href="/account">My Account</a> 
    {{ 'Log out' | customer_logout_link }}
  {% else %}
    {{ 'Log in' | customer_login_link }} 
    {% if shop.customer_accounts_optional %}
      {{ 'Create an account' | customer_register_link }}
    {% endif %}
  {% endif %}
{% endif %}
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>customer</code> is only defined when a customer is logged-in to the store. <a href="/themes/liquid-documentation/objects/customer">More info &rsaquo;</a></p>
      </td>
    </tr>
    <tr>
      <td><pre>linklists</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
<ul>
 {% for link in linklists.categories.links %}
    <li>{{ link.title | link_to: link.url }}</li>
  {% endfor %}
</ul>
{% endraw %}{% endhighlight%}
        </div>
        <p>The liquid object <code>linklists</code> contains a collection of all of the links in your shop. You can access a linklist by calling its handle on linklists. <a href="/themes/liquid-documentation/objects/linklist">More info &rsaquo;</a></p>
      </td>
    </tr>
    <tr>
      <td><pre>pages</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
<h1>{{ pages.about.title }}</h1>
<p>{{ pages.about.author }} says...</p>
<div>{{ pages.about.content }}</div>
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>pages</code> refers to all of the pages in your shop. <a href="/themes/liquid-documentation/objects/page">More info &rsaquo;</a></p>
      </td>
    </tr>
    <tr>
      <td><pre>page_description</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
{% if page_description %}
  <meta name="description" content="{{ page_description }}" /> 
{% endif %}
{% endraw %}{% endhighlight %}
        </div> 
        <p>Merchants can specify a <code>page_description</code>. That field is automatically populated with the product/collection/article description. <a href="/themes/liquid-documentation/objects/page-description">More info &rsaquo;</a>
        </p>
      </td>
    </tr>
    <tr>
      <td><pre>page_title</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
{{ page_title }}
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>page_title</code> returns the title of the current page. <a href="/themes/liquid-documentation/objects/page-title">More info &rsaquo;</a></p>
      </td>
    </tr>
    <tr>
      <td><pre>shop</pre></td>
      <td>
        <div>
        </div>
        <p>The liquid object <code>shop</code> returns information about your shop. <a href="/themes/liquid-documentation/objects/shop">More info &rsaquo;</a>
      </td>
    </tr>
    <tr>
      <td><pre>template</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
{% if template contains 'product' %}
  WE ARE ON A PRODUCT PAGE.
{% endif %}
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>template</code> returns the name of the template used to render the current page, with the .liquid extension omitted. As a best practice, it is recommended that you use the template object as a body class. <a href="/themes/liquid-documentation/objects/template">More info &rsaquo;</a></p>
      </td>
    </tr>
    <tr>
      <td><pre>settings</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
{% if settings.use_logo %}
{{ 'logo.png' | asset_url | img_tag: shop.name }}
{% else %}
<span class="no-logo">{{ shop.name }}</span>
{% endif %}
{% if settings.featured_collection and settings.featured_collection != '' and collections[settings.featured_collection].handle == settings.featured_collection and collections[settings.featured_collection].products_count > 0 %}
{% for product in collections[settings.featured_collection].products %}
  {% include 'product-loop' %}
{% endfor %}
{% endif %}
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>settings</code> gives you access to all of the theme settings. <a href="/themes/theme-development/templates/settings#settings-object">More info &rsaquo;</a></p>
      </td>
    </tr>

   <tr>
      <td><pre>theme</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
Go to your <a href="/admin/themes/{{ theme.id }}/settings">theme settings</a>.
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>theme</code> represents the currently active theme. <a href="/themes/liquid-documentation/objects/theme">More info &rsaquo;</a></p></p>
      </td>
    </tr>
   <tr>
      <td><pre>themes</pre></td>
      <td>
        <div>
{% highlight html %}{% raw %}
We have a beautiful mobile theme, it's called {{ themes.mobile.name | link_to_theme: "mobile" }}
{% endraw %}{% endhighlight %}
        </div>
        <p>The liquid object <code>themes</code> provides access to the shop's published themes. <a href="/themes/liquid-documentation/objects/theme">More info &rsaquo;</a></p>
      </td>
    </tr>

  </tbody>
</table>



