require File.dirname(__FILE__) + '/helper'

class TemplateTest < Test::Unit::TestCase
  include Liquid
  
  def test_tokenize_strings
    assert_equal [' '], Template.new.send(:tokenize, ' ')
    assert_equal ['hello world'], Template.new.send(:tokenize, 'hello world')
  end                         
  
  def test_tokenize_variables
    assert_equal ['{{funk}}'], Template.new.send(:tokenize, '{{funk}}')
    assert_equal [' ', '{{funk}}', ' '], Template.new.send(:tokenize, ' {{funk}} ')
    assert_equal [' ', '{{funk}}', ' ', '{{so}}', ' ', '{{brother}}', ' '], Template.new.send(:tokenize, ' {{funk}} {{so}} {{brother}} ')
    assert_equal [' ', '{{  funk  }}', ' '], Template.new.send(:tokenize, ' {{  funk  }} ')
  end                             
  
  def test_tokenize_blocks    
    assert_equal ['{%comment%}'], Template.new.send(:tokenize, '{%comment%}')
    assert_equal [' ', '{%comment%}', ' '], Template.new.send(:tokenize, ' {%comment%} ')
    
    assert_equal [' ', '{%comment%}', ' ', '{%endcomment%}', ' '], Template.new.send(:tokenize, ' {%comment%} {%endcomment%} ')
    assert_equal ['  ', '{% comment %}', ' ', '{% endcomment %}', ' '], Template.new.send(:tokenize, "  {% comment %} {% endcomment %} ")    
  end                                                          
  
end