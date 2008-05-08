= Liquid template engine

Liquid is a template engine which I wrote for very specific requirements

* It has to have beautiful and simple markup. 
  Template engines which don't produce good looking markup are no fun to use. 
* It needs to be non evaling and secure. Liquid templates are made so that users can edit them. You don't want to run code on your server which your users wrote. 
* It has to be stateless. Compile and render steps have to be seperate so that the expensive parsing and compiling can be done once and later on you can 
  just render it   passing in a hash with local variables and objects.

== Why should i use Liquid

* You want to allow your users to edit the appearance of your application but don't want them to run insecure code on your server.
* You want to render templates directly from the database
* You like smarty style template engines 
* You need a template engine which does HTML just as well as Emails
* You don't like the markup of your current one

== What does it look like?

	<ul id="products">  
	  {% for product in products %}
	    <li>
	      <h2>{{product.name}}</h2>
	      Only {{product.price | price }}
  
	      {{product.description | prettyprint | paragraph }}
 	    </li>      
	  {% endfor %}  
	</ul>

== Howto use Liquid

Liquid supports a very simple API based around the Liquid::Template class.
For standard use you can just pass it the content of a file and call render with a parameters hash. 

	@template = Liquid::Template.parse("hi {{name}}") # Parses and compiles the template
	@template.render( 'name' => 'tobi' )              # => "hi tobi" 