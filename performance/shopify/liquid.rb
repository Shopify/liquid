require File.dirname(__FILE__) + '/../../lib/liquid'

require File.dirname(__FILE__) + '/comment_form'
require File.dirname(__FILE__) + '/paginate'
require File.dirname(__FILE__) + '/json_filter'
require File.dirname(__FILE__) + '/money_filter'
require File.dirname(__FILE__) + '/shop_filter'
require File.dirname(__FILE__) + '/tag_filter'
require File.dirname(__FILE__) + '/weight_filter'

Liquid::Template.register_tag 'paginate', Paginate
Liquid::Template.register_tag 'form', CommentForm

Liquid::Template.register_filter JsonFilter
Liquid::Template.register_filter MoneyFilter
Liquid::Template.register_filter WeightFilter
Liquid::Template.register_filter ShopFilter
Liquid::Template.register_filter TagFilter
