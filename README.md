# Liquid template engine

## Introduction

Liquid is a template engine which I wrote for very specific requirements

* It has to have beautiful and simple markup. Template engines which don't produce good looking markup are no fun to use.
* It needs to be non evaling and secure. Liquid templates are made so that users can edit them. You don't want to run code on your server which your users wrote.
* It has to be stateless. Compile and render steps have to be seperate so that the expensive parsing and compiling can be done once and later on you can just render it passing in a hash with local variables and objects.

## Why should I use Liquid

* You want to allow your users to edit the appearance of your application but don't want them to run **insecure code on your server**.
* You want to render templates directly from the database
* You like smarty (PHP) style template engines
* You need a template engine which does HTML just as well as emails
* You don't like the markup of your current templating engine

## What does it look like?

<code>
  <ul id="products">
    {% for product in products %}
      <li>
        <h2>{{product.name}}</h2>
        Only {{product.price | price }}

        {{product.description | prettyprint | paragraph }}
      </li>
    {% endfor %}
  </ul>
</code>

## Howto use Liquid

Liquid supports a very simple API based around the Liquid::Template class.
For standard use you can just pass it the content of a file and call render with a parameters hash.

<pre>
@template = Liquid::Template.parse("hi {{name}}") # Parses and compiles the template
@template.render( 'name' => 'tobi' )              # => "hi tobi"
</pre>

## Rails integration

By default Liquid will include all helpers as Liquid filter. 

<pre>
module ApplicationHelper
  def truncate(input, length)
    input[0..length] + '...' 
  end
end
</pre>

Liquid:

<pre>
 {{ 'This is a long section of text' | truncate: 3 }} #=>   Thi... 
</pre>

And you can config it like this:
<pre>
LiquidView.included_helpers = [ApplicationHelper, MyLiquidHelper]
</pre>

If you want to liquid include filter, you config where you put liquid template:

<pre>
Liquid::Template.file_system = Liquid::LocalFileSystem.new(Rails.root.join("app","view","liquid")) 
</pre>



