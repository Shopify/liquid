require 'liquid'
require 'extras/liquid_view'

if defined? ActionView::Template and ActionView::Template.respond_to? :register_template_handler
  ActionView::Template
else
  ActionView::Base
end.register_template_handler(:liquid, LiquidView)
