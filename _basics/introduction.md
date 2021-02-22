---
title: Introduction
description: An overview of objects, tags, and filters in the Liquid template language.
redirect_from: /basics/
---

Liquid code can be categorized into [**objects**](#objects), [**tags**](#tags), and [**filters**](#filters).

## Objects

**Objects** tell Liquid where to show content on a page. Objects and variable names are denoted by double curly braces: `{% raw %}{{{% endraw %}` and `{% raw %}}}{% endraw %}`.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ page.title }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ page.title }}
```

In this case, Liquid is rendering the content of the `title` property of the `page` object, which contains the text `{{ page.title }}`.

## Tags

**Tags** create the logic and control flow for templates. They are denoted by curly braces and percent signs: `{% raw %}{%{% endraw %}` and `{% raw %}%}{% endraw %}`.

The markup used in tags does not produce any visible text. This means that you can assign variables and create conditions and loops without showing any of the Liquid logic on the page.

<p class="code-label">Input</p>
```liquid
{% raw %}
{% if user %}
  Hello {{ user.name }}!
{% endif %}
{% endraw %}
```

<p class="code-label">Output</p>
```text
Hello Adam!
```

Tags can be categorized into three types:

- [Control flow]({{ "/tags/control-flow/" | prepend: site.baseurl }})
- [Iteration]({{ "/tags/iteration/" | prepend: site.baseurl }})
- [Variable assignments]({{ "/tags/variable/" | prepend: site.baseurl }})

You can read more about each type of tag in their respective sections.

## Filters

**Filters** change the output of a Liquid object or variable. They are used within double curly braces `{% raw %}{{ }}{% endraw %}` and [variable assignment]({{ "/tags/variable/" | prepend: site.baseurl }}), and are separated by a pipe character `|`.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "/my/fancy/url" | append: ".html" }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "/my/fancy/url" | append: ".html" }}
```

Multiple filters can be used on one output. They are applied from left to right.

<p class="code-label">Input</p>
```liquid
{% raw %}
{{ "adam!" | capitalize | prepend: "Hello " }}
{% endraw %}
```

<p class="code-label">Output</p>
```text
{{ "adam!" | capitalize | prepend: "Hello " }}
```
