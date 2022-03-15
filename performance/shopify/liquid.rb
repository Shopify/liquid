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

Liquid5::Template.register_tag('paginate', Paginate)
Liquid5::Template.register_tag('form', CommentForm)

Liquid5::Template.register_filter(JsonFilter)
Liquid5::Template.register_filter(MoneyFilter)
Liquid5::Template.register_filter(WeightFilter)
Liquid5::Template.register_filter(ShopFilter)
Liquid5::Template.register_filter(TagFilter)
