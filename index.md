---
layout: default
---

{% include home-banner.html %}

Liquid is an open-source template language created by [Shopify](https://www.shopify.com) and written in Ruby. It is the backbone of Shopify themes and is used to load dynamic content on storefronts. Liquid is also used in static site generators like [Jekyll](http://jekyllrb.com).

Liquid has been in production use since June 2006 and is now used by many other hosted web applications.

It was developed for usage in Ruby on Rails web applications and integrates seamlessly as a plugin but it also works well as a stand-alone library.

## Introduction

Liquid is a language for writing and rendering templates. This means that you can reduce code duplication by displaying and manipulating content on web pages without changing a site's code.

### Objects

**Objects** tell Liquid where to show content on a page.

Objects and variable names are denoted by double curly braces: `{% raw %}{{{% endraw %}` and `{% raw %}}}{% endraw %}`.

For example, you can show basic content like a page title using a Liquid object:

```liquid
{% raw %}
{{ page.title }}
{% endraw %}
```

```text
Overview
```

In this case, Liquid is rendering the content of an object called `page.title`, and that object contains the text `Overview`.

[Filters](/filters) can change the way objects are rendered.

### Tags

**Tags** create the logic and control flow for your template, including variable assignments, conditionals, and loops.

Tags are denoted by curly braces and percent signs: `{% raw %}{%{% endraw %}` and `{% raw %}%}{% endraw %}`.

Tag markup does not resolve to text. This means that you can assign variables and create conditionals and loops without showing any of the Liquid logic on the page.

#### Conditionals

Conditionals can change the information Liquid shows using programming logic:

```liquid
{% raw %}
{% if user %}
  Hello {{ user.name }}!
{% endif %}

{% endraw %}
```

```text
Hello Adam!
```

This conditional statement `if user` checks to see if an object called `user` exists. If the condition is *true* (that is, if there is a `user`), Liquid shows any content that is contained between the `if` and `endif` tags.

In this case, our user's `name` is Adam, so the template prints `Hello Adam!`.

#### Loops

You can also use tags to loop over a list or array of objects:

```liquid
{% raw %}

{% for item in collection %}
  I have a {{ item }}
{% endfor %}

{% endraw %}
```

```text
I have a shirt
I have a pants
I have a banana
I have a bucket
```

The statement `for item in collection` tells Liquid to show the content between the `for` and `endfor` tags one time for every `item` in the `collection` object.

You can use any arbitrary name (this example used `item`) to reference the items to loop through.
