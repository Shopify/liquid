---
layout: default
title: String Filters
nav:
  group: Filters
  weight: '4'
---

# String Filters

String filters are used to manipulate outputs and variables of the <a href="/themes/liquid-documentation/basics/types/#strings">string</a> type. 

{% table_of_contents %}



{% anchor_link "append", "append" %}

<p>Appends characters to a string.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'sales' | append: '.jpg' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
sales.jpg
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "camelcase", "camelcase" %}


<p>Converts a string into CamelCase.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'coming-soon' | camelcase }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
ComingSoon
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "capitalize", "capitalize" %}

<p>Capitalizes the first word in a string</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'capitalize me' | capitalize }}
{% endraw %}{% endhighlight %}
</div>
<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Capitalize me
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "downcase", "downcase" %}

<p>Converts a string into lowercase.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'UPPERCASE' | downcase }}
{% endraw %}{% endhighlight %}
</div>
**Ouput**

<div>
{% highlight html%}{% raw %}
uppercase
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "escape", "escape" %}

<p>Escapes a string.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ "<p>test</p>" | escape }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
 <!-- The <p> tags are not rendered -->
<p>test</p>
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "handle/handleize", "handle" %}

Formats a string into a <a href="/themes/liquid-documentation/basics/handle/">handle</a>. 

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ '100% M & Ms!!!' | handleize }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html%}{% raw %}
100-m-ms
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "md5", "md5" %}

Converts a string into an MD5 hash. 

<p>An example use case for this filter is showing the Gravatar  image associated with the poster of a blog comment:</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
<img src="http://www.gravatar.com/avatar/{{ comment.email | remove: ' ' | strip_newlines | downcase | md5 }}" />
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
<img src="http://www.gravatar.com/avatar/2a95ab7c950db9693c2ceb767784c201" />
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "newline_to_br", "newline_to_br" %}

<p>Inserts a &lt;br &gt; linebreak HTML tag in front of each line break in a string.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% capture var %}
One 
Two
Three
{% endcapture %}
{{ var | newline_to_br }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
One <br>
Two<br>
Three<br>
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "pluralize", "pluralize" %}

Outputs the singular or plural version of a string based on the value of a number. The first parameter is the singular string and the second parameter is the plural string. 

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ cart.item_count }}
{{ cart.item_count | pluralize: 'item', 'items' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html%}{% raw %}
3 items
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "prepend", "prepend" %}


<p>Prepends characters to a string.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'sale' | prepend: 'Made a great ' }}
{% endraw %}{% endhighlight %}
</div>
<p class="output">Output</p>

<div>
{% highlight html%}{% raw %}
Made a great sale
{% endraw %}{% endhighlight %}
</div>





{% anchor_link "remove", "remove" %}

<p>Removes all occurrences of a substring from a string.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ "Hello, world. Goodbye, world." | remove: "world" }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Hello, . Goodbye, .
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "remove_first", "remove_first" %}

<p>Removes only the first occurrence of a substring from a string.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ "Hello, world. Goodbye, world." | remove_first: "world" }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Hello, . Goodbye, world.
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "replace", "replace" %}

<p>Replaces all occurrences of a string with a substring.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- product.title = "Awesome Shoes" -->
{{ product.title | replace: 'Awesome', 'Mega' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Mega Shoes
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "replace_first", "replace_first" %}

<p>Replaces the first occurrence of a string with a substring.</p>

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
<!-- product.title = "Awesome Awesome Shoes" -->
{{ product.title | replace_first: 'Awesome', 'Mega' }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
Mega Awesome Shoes
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "split", "split" %}

The <code>split</code> filter takes on a substring as a parameter. The substring is used as a delimiter to divide a string into an array.


<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{% assign words = "Uses cheat codes, calls the game boring." | split: ' ' %}
First word: {{ words.first }}
First word: {{ words[0] }}
Second word: {{ words[1] }}
Last word: {{ words.last }}
All words: {{ words | join: ', ' }}

{% for word in words %}
{{ word }} 
{% endfor %}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html%}{% raw %}
First word: Uses
First word: Uses
Second word: cheat
Last word: boring.
All words: Uses, cheat, codes,, calls, the, game, boring.

Uses cheat codes, calls the game boring.
{% endraw %}{% endhighlight %}
</div>





{% anchor_link "strip", "strip" %}

<p>Strips tabs, spaces, and newlines (all whitespace) from the left and right side of a string. </p> 

<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ '   too many spaces      ' | strip }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
too many spaces
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "lstrip", "lstrip" %}


<p>Strips tabs, spaces, and newlines (all whitespace) from the <strong>left</strong> side of a string.</p> 

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
"{{ '   too many spaces           ' | lstrip }}"
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
{% highlight html %}{% raw %}
<!-- Notice the empty spaces to the right of the string -->
too many spaces           
{% endraw %}{% endhighlight %}
</div>





{% anchor_link "rstrip", "rstrip" %}

<p>Strips tabs, spaces, and newlines (all whitespace) from the <strong>right</strong> side of a string. </p> 

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ '              too many spaces      ' | strip }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>

<div>
<!-- Notice the empty spaces to the right of the string -->
{% highlight html %}{% raw %}
                 too many spaces     
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "strip_html", "strip_html" %}

<p>Strips all HTML tags from a string.</p>

<p class="input">Input</p> 
<div>
{% highlight html %}{% raw %}
{{ "<h1>Hello</h1> World" | strip_html }}
{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
Hello World
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "strip_newlines", "strip_newlines" %}

<p>Removes any line breaks/newlines from a string.</p>

<div>
{% highlight html %}{% raw %}
{{ product.description | strip_newlines }}
{% endraw %}{% endhighlight %}
</div>









{% anchor_link "to_number", "to_number" %}

<p>Converts a string into a number.</p>

<p><strong>Note</strong>: when you define a variable using the <a href="/themes/liquid-documentation/tags/variable-tags/#capture">capture</a> tag, the result is always a string. Theme Settings variables are also strings by default. 

<p>For example, the following will produce an error, since the <code>num</code> variable is still a string:</p>

<div>
{% highlight html %}{% raw %}
{% capture num %}10000{% endcapture %}
{% if num > 9000 %}
    num is over 9000!
{% endif %}
{% endraw %}{% endhighlight %}
</div>

<p>By using the <code>to_number</code> filter on the <code>num</code> variable, it can be compared to another number.

<div>
{% highlight html %}{% raw %}
{% capture num %}10000{% endcapture %}
{% if num | to_number > 9000 %}
    num is over 9000!
{% endif %}
{% endraw %}{% endhighlight %}
</div>








{% anchor_link "truncate", "truncate" %}

<p>Truncates a string down to 'x' characters, where x is the number passed as a parameter. An ellipsis (...) is appended to the string and is included in the character count.</p> 

<div>
{% highlight html %}{% raw %}
{{ "The cat came back the very next day" | truncate: 10 }}
{% endraw %}{% endhighlight %}
</div>

<div>
{% highlight html %}{% raw %}
The cat...
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "truncatewords", "truncatewords" %}


<p>Truncates a string down to 'x' words, where x is the number passed as a parameter. An ellipsis (...) is appended to the truncated string.</p>


<p class="input">Input</p>
<div>
{% highlight html %}{% raw %}
{{ "The cat came back the very next day" | truncatewords: 4 }}{% endraw %}{% endhighlight %}
</div>

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
The cat came back...
{% endraw %}{% endhighlight %}
</div>







{% anchor_link "upcase", "upcase" %}

<p>Converts a string into uppercase.</p>

<p class="input">Input</p>

<div>
{% highlight html %}{% raw %}
{{ 'i want this to be uppercase' | upcase }}
{% endraw %}{% endhighlight %}
</div>
<p class="output">Output</p>

<div>
{% highlight html%}{% raw %}
I WANT THIS TO BE UPPERCASE
{% endraw %}{% endhighlight %}
</div>





{% anchor_link "url_escape", "url_escape" %}

Identifies all characters in a string that are not allowed in URLS, and replaces the characters with their escaped variants.

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ "<hello> & <shopify>" | url_escape }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
%3Chello%3E%20&%20%3Cshopify%3E
{% endraw %}{% endhighlight %}
</div>






{% anchor_link "url_param_escape", "url_param_escape" %}

<p>Replaces all characters in a string that are not allowed in URLs with their escaped variants, including the ampersand (&).</p>

<p class="input">Input</p>
{% highlight html %}{% raw %}
{{ "<hello> & <shopify>" | url_param_escape }}
{% endraw %}{% endhighlight %}

<p class="output">Output</p>
<div>
{% highlight html %}{% raw %}
%3Chello%3E%20%26%20%3Cshopify%3E
{% endraw %}{% endhighlight %}
</div>




