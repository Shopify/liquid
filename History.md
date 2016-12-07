# Liquid Change Log

## 4.0.0 / not yet released / branch "master"

### Changed
* Render an opaque internal error by default for non-Liquid::Error (#835) [Dylan Thacker-Smith]
* Ruby 2.0 support dropped (#832) [Dylan Thacker-Smith]
* Add to_number Drop method to allow custom drops to work with number filters (#731)
* Add strict_variables and strict_filters options to detect undefined references (#691)
* Improve loop performance (#681) [Florian Weingarten]
* Rename Drop method `before_method` to `liquid_method_missing` (#661) [Thierry Joyal]
* Add url_decode filter to invert url_encode (#645) [Larry Archer]
* Add global_filter to apply a filter to all output (#610) [Loren Hale]
* Add compact filter (#600) [Carson Reinke]
* Rename deprecated "has_key?" and "has_interrupt?" methods (#593) [Florian Weingarten]
* Include template name with line numbers in render errors (574) [Dylan Thacker-Smith]
* Add sort_natural filter (#554) [Martin Hanzel]
* Add forloop.parentloop as a reference to the parent loop (#520) [Justin Li]
* Block parsing moved to BlockBody class (#458) [Dylan Thacker-Smith]
* Add concat filter to concatenate arrays (#429) [Diogo Beato]
* Ruby 1.9 support dropped (#491) [Justin Li]
* Liquid::Template.file_system's read_template_file method is no longer passed the context. (#441) [James Reid-Smith]
* Remove support for `liquid_methods`
* Liquid::Template.register_filter raises when the module overrides registered public methods as private or protected (#705) [Gaurav Chande]

### Fixed
* Fix map filter when value is a Proc (#672) [Guillaume Malette]
* Fix truncate filter when value is not a string (#672) [Guillaume Malette]
* Fix behaviour of escape filter when input is nil (#665) [Tanel Jakobsoo]
* Fix sort filter behaviour with empty array input (#652) [Marcel Cary]
* Fix test failure under certain timezones (#631) [Dylan Thacker-Smith]
* Fix bug in uniq filter (#595) [Florian Weingarten]
* Fix bug when "blank" and "empty" are used as variable names (#592) [Florian Weingarten]
* Fix condition parse order in strict mode (#569) [Justin Li]
* Fix naming of the "context variable" when dynamically including a template (#559) [Justin Li]
* Gracefully accept empty strings in the date filter (#555) [Loren Hale]
* Fix capturing into variables with a hyphen in the name (#505) [Florian Weingarten]
* Fix case sensitivity regression in date standard filter (#499) [Kelley Reynolds]
* Disallow filters with no variable in strict mode (#475) [Justin Li]
* Disallow variable names in the strict parser that are not valid in the lax parser (#463) [Justin Li]
* Fix BlockBody#warnings taking exponential time to compute (#486) [Justin Li]

## 3.0.5 / 2015-07-23 / branch "3-0-stable"

* Fix test failure under certain timezones [Dylan Thacker-Smith]

## 3.0.4 / 2015-07-17

* Fix chained access to multi-dimensional hashes [Florian Weingarten]

## 3.0.3 / 2015-05-28

* Fix condition parse order in strict mode (#569) [Justin Li]

## 3.0.2 / 2015-04-24

* Expose VariableLookup private members (#551) [Justin Li]
* Documentation fixes

## 3.0.1 / 2015-01-23

* Remove duplicate `index0` key in TableRow tag (#502) [Alfred Xing]

## 3.0.0 / 2014-11-12

* Removed Block#end_tag. Instead, override parse with `super` followed by your code. See #446 [Dylan Thacker-Smith]
* Fixed condition with wrong data types (#423) [Bogdan Gusiev]
* Add url_encode to standard filters (#421) [Derrick Reimer]
* Add uniq to standard filters [Florian Weingarten]
* Add exception_handler feature (#397) and #254 [Bogdan Gusiev, Florian Weingarten]
* Optimize variable parsing to avoid repeated regex evaluation during template rendering #383 [Jason Hiltz-Laforge]
* Optimize checking for block interrupts to reduce object allocation #380 [Jason Hiltz-Laforge]
* Properly set context rethrow_errors on render! #349 [Thierry Joyal]
* Fix broken rendering of variables which are equal to false (#345) [Florian Weingarten]
* Remove ActionView template handler [Dylan Thacker-Smith]
* Freeze lots of string literals for new Ruby 2.1 optimization (#297) [Florian Weingarten]
* Allow newlines in tags and variables (#324) [Dylan Thacker-Smith]
* Tag#parse is called after initialize, which now takes options instead of tokens as the 3rd argument. See #321 [Dylan Thacker-Smith]
* Raise `Liquid::ArgumentError` instead of `::ArgumentError` when filter has wrong number of arguments #309 [Bogdan Gusiev]
* Add a to_s default for liquid drops (#306) [Adam Doeler]
* Add strip, lstrip, and rstrip to standard filters [Florian Weingarten]
* Make if, for & case tags return complete and consistent nodelists (#250) [Nick Jones]
* Prevent arbitrary method invocation on condition objects (#274) [Dylan Thacker-Smith]
* Don't call to_sym when creating conditions for security reasons (#273) [Bouke van der Bijl]
* Fix resource counting bug with respond_to?(:length) (#263) [Florian Weingarten]
* Allow specifying custom patterns for template filenames (#284) [Andrei Gladkyi]
* Allow drops to optimize loading a slice of elements (#282) [Tom Burns]
* Support for passing variables to snippets in subdirs (#271) [Joost Hietbrink]
* Add a class cache to avoid runtime extend calls (#249) [James Tucker]
* Remove some legacy Ruby 1.8 compatibility code (#276) [Florian Weingarten]
* Add default filter to standard filters (#267) [Derrick Reimer]
* Add optional strict parsing and warn parsing (#235) [Tristan Hume]
* Add I18n syntax error translation (#241) [Simon Hørup Eskildsen, Sirupsen]
* Make sort filter work on enumerable drops (#239) [Florian Weingarten]
* Fix clashing method names in enumerable drops (#238) [Florian Weingarten]
* Make map filter work on enumerable drops (#233) [Florian Weingarten]
* Improved whitespace stripping for blank blocks, related to #216 [Florian Weingarten]

## 2.6.3 / 2015-07-23 / branch "2-6-stable"

* Fix test failure under certain timezones [Dylan Thacker-Smith]

## 2.6.2 / 2015-01-23

* Remove duplicate hash key [Parker Moore]

## 2.6.1 / 2014-01-10

Security fix, cherry-picked from master (4e14a65):
* Don't call to_sym when creating conditions for security reasons (#273) [Bouke van der Bijl]
* Prevent arbitrary method invocation on condition objects (#274) [Dylan Thacker-Smith]

## 2.6.0 / 2013-11-25

IMPORTANT: Liquid 2.6 is going to be the last version of Liquid which maintains explicit Ruby 1.8 compatability.
The following releases will only be tested against Ruby 1.9 and Ruby 2.0 and are likely to break on Ruby 1.8.

* Bugfix for #106: fix example servlet [gnowoel]
* Bugfix for #97: strip_html filter supports multi-line tags [Jo Liss]
* Bugfix for #114: strip_html filter supports style tags [James Allardice]
* Bugfix for #117: 'now' support for date filter in Ruby 1.9 [Notre Dame Webgroup]
* Bugfix for #166: truncate filter on UTF-8 strings with Ruby 1.8 [Florian Weingarten]
* Bugfix for #204: 'raw' parsing bug [Florian Weingarten]
* Bugfix for #150: 'for' parsing bug [Peter Schröder]
* Bugfix for #126: Strip CRLF in strip_newline [Peter Schröder]
* Bugfix for #174, "can't convert Fixnum into String" for "replace" [jsw0528]
* Allow a Liquid::Drop to be passed into Template#render [Daniel Huckstep]
* Resource limits [Florian Weingarten]
* Add reverse filter [Jay Strybis]
* Add utf-8 support
* Use array instead of Hash to keep the registered filters [Tasos Stathopoulos]
* Cache tokenized partial templates [Tom Burns]
* Avoid warnings in Ruby 1.9.3 [Marcus Stollsteimer]
* Better documentation for 'include' tag (closes #163) [Peter Schröder]
* Use of BigDecimal on filters to have better precision (closes #155) [Arthur Nogueira Neves]

## 2.5.5 / 2014-01-10 / branch "2-5-stable"

Security fix, cherry-picked from master (4e14a65):
* Don't call to_sym when creating conditions for security reasons (#273) [Bouke van der Bijl]
* Prevent arbitrary method invocation on condition objects (#274) [Dylan Thacker-Smith]

## 2.5.4 / 2013-11-11

* Fix "can't convert Fixnum into String" for "replace" (#173), [jsw0528]

## 2.5.3 / 2013-10-09

* #232, #234, #237: Fix map filter bugs [Florian Weingarten]

## 2.5.2 / 2013-09-03 / deleted

Yanked from rubygems, as it contained too many changes that broke compatibility. Those changes will be on following major releases.

## 2.5.1 / 2013-07-24

* #230: Fix security issue with map filter, Use invoke_drop in map filter [Florian Weingarten]

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
