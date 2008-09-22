# LiquidView is a action view extension class. You can register it with rails
# and use liquid as an template system for .liquid files
#
# Example
# 
#   ActionView::Base::register_template_handler :liquid, LiquidView
class LiquidView

  def initialize(action_view)
    @action_view = action_view
  end
  

  def render(template, local_assigns_for_rails_less_than_2_1_0 = nil)
    @action_view.controller.headers["Content-Type"] ||= 'text/html; charset=utf-8'
    assigns = @action_view.assigns.dup
    
    # template is a Template object in Rails >=2.1.0, a source string previously.
    if template.respond_to? :source
      source = template.source
      local_assigns = template.locals
    else
      source = template
      local_assigns = local_assigns_for_rails_less_than_2_1_0
    end

    if content_for_layout = @action_view.instance_variable_get("@content_for_layout")
      assigns['content_for_layout'] = content_for_layout
    end
    assigns.merge!(local_assigns)
    
    liquid = Liquid::Template.parse(source)
    liquid.render(assigns, :filters => [@action_view.controller.master_helper_module], :registers => {:action_view => @action_view, :controller => @action_view.controller})
  end

  def compilable?
    false
  end

end