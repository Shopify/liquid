class CommentForm < Liquid::Block                                             
  Syntax = /(#{Liquid::VariableSignature}+)/   

  def initialize(tag_name, markup, tokens)
    if markup =~ Syntax
      @variable_name = $1
      @attributes = {}
    else
      raise SyntaxError.new("Syntax Error in 'comment_form' - Valid syntax: comment_form [article]")
    end
    
    super
  end

  def render(context)          
    article = context[@variable_name]
              
    context.stack do       
      context['form'] = {
        'posted_successfully?' => context.registers[:posted_successfully],
        'errors' => context['comment.errors'],
        'author' => context['comment.author'],
        'email'  => context['comment.email'],
        'body'   => context['comment.body']
      }
      wrap_in_form(article, render_all(@nodelist, context))
    end
  end          
    
  def wrap_in_form(article, input)    
    %Q{<form id="article-#{article.id}-comment-form" class="comment-form" method="post" action="">\n#{input}\n</form>}    
  end
end
