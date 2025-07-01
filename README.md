[![Build status](https://github.com/Shopify/liquid/actions/workflows/liquid.yml/badge.svg)](https://github.com/Shopify/liquid/actions/workflows/liquid.yml)
[![Inline docs](http://inch-ci.org/github/Shopify/liquid.svg?branch=master)](http://inch-ci.org/github/Shopify/liquid)

# Liquid template engine

* [Contributing guidelines](CONTRIBUTING.md)
* [Version history](History.md)
* [Liquid documentation from Shopify](https://shopify.dev/docs/api/liquid)
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

Install Liquid by adding `gem 'liquid'` to your gemfile.

Liquid supports a very simple API based around the Liquid::Template class.
For standard use you can just pass it the content of a file and call render with a parameters hash.

```ruby
@template = Liquid::Template.parse("hi {{name}}") # Parses and compiles the template
@template.render('name' => 'tobi')                # => "hi tobi"
```

### Concept of Environments

In Liquid, a "Environment" is a scoped environment that encapsulates custom tags, filters, and other configurations. This allows you to define and isolate different sets of functionality for different contexts, avoiding global overrides that can lead to conflicts and unexpected behavior.

By using environments, you can:

1. **Encapsulate Logic**: Keep the logic for different parts of your application separate.
2. **Avoid Conflicts**: Prevent custom tags and filters from clashing with each other.
3. **Improve Maintainability**: Make it easier to manage and understand the scope of customizations.
4. **Enhance Security**: Limit the availability of certain tags and filters to specific contexts.

We encourage the use of Environments over globally overriding things because it promotes better software design principles such as modularity, encapsulation, and separation of concerns.

Here's an example of how you can define and use Environments in Liquid:

```ruby
user_environment = Liquid::Environment.build do |environment|
  environment.register_tag("renderobj", RenderObjTag)
end

Liquid::Template.parse(<<~LIQUID, environment: user_environment)
  {% renderobj src: "path/to/model.obj" %}
LIQUID
```

In this example, `RenderObjTag` is a custom tag that is only available within the `user_environment`.

Similarly, you can define another environment for a different context, such as email templates:

```ruby
email_environment = Liquid::Environment.build do |environment|
  environment.register_tag("unsubscribe_footer", UnsubscribeFooter)
end

Liquid::Template.parse(<<~LIQUID, environment: email_environment)
  {% unsubscribe_footer %}
LIQUID
```

By using Environments, you ensure that custom tags and filters are only available in the contexts where they are needed, making your Liquid templates more robust and easier to manage. For smaller projects, a global environment is available via `Liquid::Environment.default`.

### Error Modes

Setting the error mode of Liquid lets you specify how strictly you want your templates to be interpreted.
Normally the parser is very lax and will accept almost anything without error. Unfortunately this can make
it very hard to debug and can lead to unexpected behaviour.

Liquid also comes with a stricter parser that can be used when editing templates to give better error messages
when templates are invalid. You can enable this new parser like this:

```ruby
Liquid::Environment.default.error_mode = :strict
Liquid::Environment.default.error_mode = :strict # Raises a SyntaxError when invalid syntax is used
Liquid::Environment.default.error_mode = :warn # Adds strict errors to template.errors but continues as normal
Liquid::Environment.default.error_mode = :lax # The default mode, accepts almost anything.
```

If you want to set the error mode only on specific templates you can pass `:error_mode` as an option to `parse`:
```ruby
Liquid::Template.parse(source, error_mode: :strict)
```
This is useful for doing things like enabling strict mode only in the theme editor.

It is recommended that you enable `:strict` or `:warn` mode on new apps to stop invalid templates from being created.
It is also recommended that you use it in the template editors of existing apps to give editors better error messages.

### Undefined variables and filters

By default, the renderer doesn't raise or in any other way notify you if some variables or filters are missing, i.e. not passed to the `render` method.
You can improve this situation by passing `strict_variables: true` and/or `strict_filters: true` options to the `render` method.
When one of these options is set to true, all errors about undefined variables and undefined filters will be stored in `errors` array of a `Liquid::Template` instance.
Here are some examples:

```ruby
template = Liquid::Template.parse("{{x}} {{y}} {{z.a}} {{z.b}}")
template.render({ 'x' => 1, 'z' => { 'a' => 2 } }, { strict_variables: true })
#=> '1  2 ' # when a variable is undefined, it's rendered as nil
template.errors
#=> [#<Liquid::UndefinedVariable: Liquid error: undefined variable y>, #<Liquid::UndefinedVariable: Liquid error: undefined variable b>]
```

```ruby
template = Liquid::Template.parse("{{x | filter1 | upcase}}")
template.render({ 'x' => 'foo' }, { strict_filters: true })
#=> '' # when at least one filter in the filter chain is undefined, a whole expression is rendered as nil
template.errors
#=> [#<Liquid::UndefinedFilter: Liquid error: undefined filter filter1>]
```

If you want to raise on a first exception instead of pushing all of them in `errors`, you can use `render!` method:

```ruby
template = Liquid::Template.parse("{{x}} {{y}}")
template.render!({ 'x' => 1}, { strict_variables: true })
#=> Liquid::UndefinedVariable: Liquid error: undefined variable y
```

### Usage tracking

To help track usages of a feature or code path in production, we have released opt-in usage tracking. To enable this, we provide an empty `Liquid:: Usage.increment` method which you can customize to your needs. The feature is well suited to https://github.com/Shopify/statsd-instrument. However, the choice of implementation is up to you.

Once you have enabled usage tracking, we recommend reporting any events through Github Issues that your system may be logging. It is highly likely this event has been added to consider deprecating or improving code specific to this event, so please raise any concerns.
