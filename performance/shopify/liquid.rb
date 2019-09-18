# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__ + '/../../lib')
require_relative '../../lib/liquid'

require_relative 'comment_form'
require_relative 'paginate'
require_relative 'json_filter'
require_relative 'money_filter'
require_relative 'shop_filter'
require_relative 'tag_filter'
require_relative 'weight_filter'

Liquid::Template.register_tag('paginate', Paginate)
Liquid::Template.register_tag('form', CommentForm)

Liquid::Template.register_filter(JsonFilter)
Liquid::Template.register_filter(MoneyFilter)
Liquid::Template.register_filter(WeightFilter)
Liquid::Template.register_filter(ShopFilter)
Liquid::Template.register_filter(TagFilter)
