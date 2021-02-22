---
title: Template
description: An overview of template tags in the Liquid template language.
redirect_from:
  - /tags/comment/
  - /tags/raw/
---

Template tags tell Liquid where to disable processing for comments or non-Liquid markup, and how to establish relations among template files.

## comment

Allows you to leave un-rendered code inside a Liquid template. Any text within the opening and closing `comment` blocks will not be printed, and any Liquid code within will not be executed.

<p class="code-label">Input</p>
```liquid
{% raw %}
Anything you put between {% comment %} and {% endcomment %} tags
is turned into a comment.
{% endraw %}
```

<p class="code-label">Output</p>
```liquid
Anything you put between {% comment %} and {% endcomment %} tags
is turned into a comment.
```

## raw

Temporarily disables tag processing. This is useful for generating certain content (e.g. Mustache, Handlebars) that uses conflicting syntax.

<p class="code-label">Input</p>
<pre class="highlight">
<code>{% raw %}
&#123;&#37; raw &#37;&#125;
  In Handlebars, {{ this }} will be HTML-escaped, but
  {{{ that }}} will not.
&#123;&#37; endraw &#37;&#125;
{% endraw %}</code>
</pre>

<p class="code-label">Output</p>
```text
{% raw %}In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not.{% endraw %}
```

## liquid {%- include version-badge.html version="5.0.0" %}

Encloses multiple tags within one set of delimiters, to allow writing Liquid logic more concisely.

```liquid
{% raw %}
{% liquid
case section.blocks.size
when 1
  assign column_size = ''
when 2
  assign column_size = 'one-half'
when 3
  assign column_size = 'one-third'
else
  assign column_size = 'one-quarter'
endcase %}
{% endraw %}
```

## echo {%- include version-badge.html version="5.0.0" %}

Outputs an expression in the rendered HTML. This is identical to wrapping an expression in `{% raw %}{{{% endraw %}` and `{% raw %}}}{% endraw %}`, but works inside [`liquid`](#liquid) tags and supports [filters]({{ "/basics/introduction/#filters" | prepend: site.baseurl }}).

<p class="code-label">Input</p>
```liquid
{% raw %}
{% liquid
for product in collection.products
  echo product.title | capitalize
endfor %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
Hat Shirt Pants
```

## render {%- include version-badge.html version="5.0.0" %}

Insert the rendered content of another template within the current template.

```liquid
{% raw %}
{% render "template-name" %}
{% endraw %}
```

Note that you don't need to write the file's `.liquid` extension.

The code within the rendered template does **not** automatically have access to the variables assigned using [variable tags]({{ "/tags/variable/" | prepend: site.baseurl }}) within the parent template. Similarly, variables assigned within the rendered template can't be accessed by code in any other template.

### Passing variables to a template

Variables assigned using [variable tags]({{ "/tags/variable/" | prepend: site.baseurl }}) can be passed to a template by listing them as parameters on the `render` tag.

```liquid
{% raw %}
{% assign my_variable = "apples" %}
{% render "name", my_variable: my_variable, my_other_variable: "oranges" %}
{% endraw %}
```

## render (parameters)

One or more objects can be passed to a template.

```liquid
{% raw %}
{% assign featured_product = all_products["product_handle"] %}
{% render "product", product: featured_product %}
{% endraw %}
```

### with

A single object can be passed to a template by using the `with` and `as` parameters.

```liquid
{% raw %}
{% assign featured_product = all_products["product_handle"] %}
{% render "product" with featured_product as product %}
{% endraw %}
```

In the example above, the `product` variable in the rendered template will hold the value of `featured_product` from the parent template.

### for

A template can be rendered once for each value of an enumerable object by using the `for` and `as` parameters.

```liquid
{% raw %}
{% assign variants = product.variants %}
{% render "product_variant" for variants as variant %}
{% endraw %}
```

In the example above, the template will be rendered once for each variant of the product, and the `variant` variable will hold a different product variant object for each iteration.

When using the `for` parameter, the [`forloop`](https://shopify.dev/docs/themes/liquid/reference/objects/for-loops) object is accessible within the rendered template.

## include

Insert the rendered content of another template within the current template.

```liquid
{% raw %}
{% include "template-name" %}
{% endraw %}
```

The `include` tag works similarly to the [`render`](#render) tag, but it allows the code inside of the rendered template to access and overwrite the variables within its parent template. The `include` tag has been deprecated because the way that it handles variables reduces performance and makes Liquid code harder to both read and maintain.

Note that when a template is rendered using the [`render`](#render) tag, the `include` tag may not be used within the template.
