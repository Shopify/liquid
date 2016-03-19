---
title: Introduction
---

Liquid code can be categorized into [**objects**](#objects), [**tags**](#tags), and [**filters**](#filters).

## Objects

**Objects** tell Liquid where to show content on a page. Objects and variable names are denoted by double curly braces: `{% raw %}{{{% endraw %}` and `{% raw %}}}{% endraw %}`.


```liquid
{% raw %}
{{ page.title }}
{% endraw %}
```

```text
Introduction
```

In this case, Liquid is rendering the content of an object called `page.title`, and that object contains the text `Introduction`.

## Tags

**Tags** create the logic and control flow for templates. They are denoted by curly braces and percent signs: `{% raw %}{%{% endraw %}` and `{% raw %}%}{% endraw %}`.

The markup used in tags does not produce any visible text. This means that you can assign variables and create conditions and loops without showing any of the Liquid logic on the page.

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

Tags can be categorized into three types:

- [Control flow]({{ "/tags/control-flow" | prepend: site.baseurl }})
- [Iteration]({{ "/tags/iteration" | prepend: site.baseurl }})
- [Variable assignments]({{ "/tags/variable" | prepend: site.baseurl }})

You can read more about each type of tag in their respective sections.


## Filters

**Filters** change the output of a Liquid object. They are using within an output and are separated by a `|`.

```liquid
{% raw %}
{{ "/my/fancy/url" | append: ".html" }}
{% endraw %}
```

```text
{{ "/my/fancy/url" | append: ".html" }}
```
