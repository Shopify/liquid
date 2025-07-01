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

default_environment = Liquid::Environment.default
default_environment.register_tag('paginate', Paginate)
default_environment.register_tag('form', CommentForm)

default_environment.register_filter(JsonFilter)
default_environment.register_filter(MoneyFilter)
default_environment.register_filter(WeightFilter)
default_environment.register_filter(ShopFilter)
default_environment.register_filter(TagFilter)
