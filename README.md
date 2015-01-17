[![Build Status](https://api.travis-ci.org/Shopify/liquid.svg?branch=master)](http://travis-ci.org/Shopify/liquid)
[![Inline docs](http://inch-ci.org/github/Shopify/liquid.svg?branch=master)](http://inch-ci.org/github/Shopify/liquid)

# Liquid template engine

* [Contributing guidelines](CONTRIBUTING.md)
* [Version history](History.md)
* [Liquid documentation from Shopify](http://docs.shopify.com/themes/liquid-basics)
* [Liquid Wiki at GitHub](https://github.com/Shopify/liquid/wiki)
* [Website](http://liquidmarkup.org/)

## Introduction

Liquid is a template engine which was written with very specific requirements:

* It has to have beautiful and simple markup. Template engines which don't produce good looking markup are no fun to use.
* It needs to be non evaling and secure. Liquid templates are made so that users can edit them. You don't want to run code on your server which your users wrote.
* It has to be stateless. Compile and render steps have to be separate so that the expensive parsing and compiling can be done once and later on you can just render it passing in a hash with local variables and objects.

## Why you should use Liquid

* You want to allow your users to edit the appearance of your application but don't want them to run **insecure code on your server**.
* You want to render templates directly from the database.
* You like smarty (PHP) style template engines.
* You need a template engine which does HTML just as well as emails.
* You don't like the markup of your current templating engine.

## What does it look like?

```html
<ul id="products">
  {% for product in products %}
    <li>
      <h2>{{ product.name }}</h2>
      Only {{ product.price | price }}

      {{ product.description | prettyprint | paragraph }}
    </li>
  {% endfor %}
</ul>
```

## How to use Liquid

Liquid supports a very simple API based around the Liquid::Template class.
For standard use you can just pass it the content of a file and call render with a parameters hash.

```ruby
@template = Liquid::Template.parse("hi {{name}}") # Parses and compiles the template
@template.render('name' => 'tobi')                # => "hi tobi"
```

### Error Modes

Setting the error mode of Liquid lets you specify how strictly you want your templates to be interpreted.
Normally the parser is very lax and will accept almost anything without error. Unfortunately this can make
it very hard to debug and can lead to unexpected behaviour. 

Liquid also comes with a stricter parser that can be used when editing templates to give better error messages
when templates are invalid. You can enable this new parser like this:

```ruby
Liquid::Template.error_mode = :strict # Raises a SyntaxError when invalid syntax is used
Liquid::Template.error_mode = :warn # Adds errors to template.errors but continues as normal
Liquid::Template.error_mode = :lax # The default mode, accepts almost anything.
```

If you want to set the error mode only on specific templates you can pass `:error_mode` as an option to `parse`:
```ruby
Liquid::Template.parse(source, :error_mode => :strict)
```
This is useful for doing things like enabling strict mode only in the theme editor.

It is recommended that you enable `:strict` or `:warn` mode on new apps to stop invalid templates from being created.
It is also recommended that you use it in the template editors of existing apps to give editors better error messages.
