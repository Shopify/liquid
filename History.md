# Liquid Version History

IMPORTANT: Liquid 2.6 is going to be the last version of Liquid which maintains explicit Ruby 1.8 compatability.
The following releases will only be tested against Ruby 1.9 and Ruby 2.0 and are likely to break on Ruby 1.8.

## 2.6.1 / 2014-01-10 / branch "2-6-stable"

Security fix, cherry-picked from master (4e14a65):
* Don't call to_sym when creating conditions for security reasons, see #273 [Bouke van der Bijl, bouk]
* Prevent arbitrary method invocation on condition objects, see #274 [Dylan Thacker-Smith, dylanahsmith]

## 2.6.0 / 2013-11-25

* ...
* Bugfix for #106: fix example servlet [gnowoel]
* Bugfix for #97: strip_html filter supports multi-line tags [Jo Liss, joliss]
* Bugfix for #114: strip_html filter supports style tags [James Allardice, jamesallardice]
* Bugfix for #117: 'now' support for date filter in Ruby 1.9 [Notre Dame Webgroup, ndwebgroup]
* Bugfix for #166: truncate filter on UTF-8 strings with Ruby 1.8 [Florian Weingarten, fw42]
* Bugfix for #204: 'raw' parsing bug [Florian Weingarten, fw42]
* Bugfix for #150: 'for' parsing bug [Peter Schröder, phoet]
* Bugfix for #126: Strip CRLF in strip_newline [Peter Schröder, phoet]
* Bugfix for #174, "can't convert Fixnum into String" for "replace" [wǒ_is神仙, jsw0528]
* Allow a Liquid::Drop to be passed into Template#render [Daniel Huckstep, darkhelmet]
* Resource limits [Florian Weingarten, fw42]
* Add reverse filter [Jay Strybis, unreal]
* Add utf-8 support
* Use array instead of Hash to keep the registered filters [Tasos Stathopoulos, astathopoulos]
* Cache tokenized partial templates [Tom Burns, boourns]
* Avoid warnings in Ruby 1.9.3 [Marcus Stollsteimer, stomar]
* Better documentation for 'include' tag (closes #163) [Peter Schröder, phoet]
* Use of BigDecimal on filters to have better precision (closes #155) [Arthur Nogueira Neves, arthurnn]

## 2.5.4 / 2013-11-11 / branch "2.5-stable"

* Fix "can't convert Fixnum into String" for "replace", see #173, [wǒ_is神仙, jsw0528]

## 2.5.3 / 2013-10-09

* #232, #234, #237: Fix map filter bugs [Florian Weingarten, fw42]

## 2.5.2 / 2013-09-03 / deleted

Yanked from rubygems, as it contained too many changes that broke compatibility. Those changes will be on following major releases.

## 2.5.1 / 2013-07-24

* #230: Fix security issue with map filter, Use invoke_drop in map filter [Florian Weingarten, fw42]

## 2.5.0 / 2013-03-06

* Prevent Object methods from being called on drops
* Avoid symbol injection from liquid
* Added break and continue statements
* Fix filter parser for args without space separators
* Add support for filter keyword arguments


## 2.4.0 / 2012-08-03

* Performance improvements
* Allow filters in `assign`
* Add `modulo` filter
* Ruby 1.8, 1.9, and Rubinius compatibility fixes
* Add support for `quoted['references']` in `tablerow`
* Add support for Enumerable to `tablerow`
* `strip_html` filter removes html comments


## 2.3.0 / 2011-10-16

* Several speed/memory improvements
* Numerous bug fixes
* Added support for MRI 1.9, Rubinius, and JRuby
* Added support for integer drop parameters
* Added epoch support to `date` filter
* New `raw` tag that suppresses parsing
* Added `else` option to `for` tag
* New `increment` tag
* New `split` filter


## 2.2.1 / 2010-08-23

* Added support for literal tags


## 2.2.0 / 2010-08-22

* Compatible with Ruby 1.8.7, 1.9.1 and 1.9.2-p0
* Merged some changed made by the community


## 1.9.0 / 2008-03-04

* Fixed gem install rake task
* Improve Error encapsulation in liquid by maintaining a own set of exceptions instead of relying on ruby build ins


## Before 1.9.0

* Added If with or / and expressions
* Implemented .to_liquid for all objects which can be passed to liquid like Strings Arrays Hashes Numerics and Booleans. To export new objects to liquid just implement .to_liquid on them and return objects which themselves have .to_liquid methods.
* Added more tags to standard library
* Added include tag ( like partials in rails )
* [...] Gazillion of detail improvements
* Added strainers as filter hosts for better security [Tobias Luetke]
* Fixed that rails integration would call filter with the wrong "self" [Michael Geary]
* Fixed bad error reporting when a filter called a method which doesn't exist. Liquid told you that it couldn't find the filter which was obviously misleading [Tobias Luetke]
* Removed count helper from standard lib. use size [Tobias Luetke]
* Fixed bug with string filter parameters failing to tolerate commas in strings. [Paul Hammond]
* Improved filter parameters. Filter parameters are now context sensitive; Types are resolved according to the rules of the context. Multiple parameters are now separated by the Liquid::ArgumentSeparator: , by default [Paul Hammond]
    {{ 'Typo' | link_to: 'http://typo.leetsoft.com', 'Typo - a modern weblog engine' }}
* Added Liquid::Drop. A base class which you can use for exporting proxy objects to liquid which can acquire more data when used in liquid. [Tobias Luetke]

  class ProductDrop < Liquid::Drop
    def top_sales
       Shop.current.products.find(:all, :order => 'sales', :limit => 10 )
    end
  end
  t = Liquid::Template.parse( ' {% for product in product.top_sales %} {{ product.name }} {% endfor %} '  )
  t.render('product' => ProductDrop.new )
* Added filter parameters support. Example: {{ date | format_date: "%Y" }} [Paul Hammond]
