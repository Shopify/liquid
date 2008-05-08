require File.dirname(__FILE__) + '/helper'

class IfElseTest < Test::Unit::TestCase
  include Liquid

  def test_if
    assert_template_result('  ',' {% if false %} this text should not go into the output {% endif %} ')
    assert_template_result('  this text should go into the output  ',
              ' {% if true %} this text should go into the output {% endif %} ')
    assert_template_result('  you rock ?','{% if false %} you suck {% endif %} {% if true %} you rock {% endif %}?')
  end

  def test_if_else
    assert_template_result(' YES ','{% if false %} NO {% else %} YES {% endif %}')
    assert_template_result(' YES ','{% if true %} YES {% else %} NO {% endif %}')
    assert_template_result(' YES ','{% if "foo" %} YES {% else %} NO {% endif %}')
  end
  
  def test_if_boolean
    assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var' => true)    
  end        
  
  def test_if_or
    assert_template_result(' YES ','{% if a or b %} YES {% endif %}', 'a' => true, 'b' => true)    
    assert_template_result(' YES ','{% if a or b %} YES {% endif %}', 'a' => true, 'b' => false)    
    assert_template_result(' YES ','{% if a or b %} YES {% endif %}', 'a' => false, 'b' => true)    
    assert_template_result('',     '{% if a or b %} YES {% endif %}', 'a' => false, 'b' => false)        

    assert_template_result(' YES ','{% if a or b or c %} YES {% endif %}', 'a' => false, 'b' => false, 'c' => true)    
    assert_template_result('',     '{% if a or b or c %} YES {% endif %}', 'a' => false, 'b' => false, 'c' => false)        
  end
  
  def test_if_or_with_operators
    assert_template_result(' YES ','{% if a == true or b == true %} YES {% endif %}', 'a' => true, 'b' => true)    
    assert_template_result(' YES ','{% if a == true or b == false %} YES {% endif %}', 'a' => true, 'b' => true)    
    assert_template_result('','{% if a == false or b == false %} YES {% endif %}', 'a' => true, 'b' => true)    
  end     
  
  def test_if_and
    assert_template_result(' YES ','{% if true and true %} YES {% endif %}')    
    assert_template_result('','{% if false and true %} YES {% endif %}')    
    assert_template_result('','{% if false and true %} YES {% endif %}')    
  end
  
  
  def test_hash_miss_generates_false
    assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo' => {})
  end
  
  def test_if_from_variable
    assert_template_result('','{% if var %} NO {% endif %}', 'var' => false)
    assert_template_result('','{% if var %} NO {% endif %}', 'var' => nil)
    assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo' => {'bar' => false})
    assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo' => {})
    assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo' => nil)
    assert_template_result('','{% if foo.bar %} NO {% endif %}', 'foo' => true)
    
    assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var' => "text")
    assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var' => true)
    assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var' => 1)
    assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var' => {})
    assert_template_result(' YES ','{% if var %} YES {% endif %}', 'var' => [])
    assert_template_result(' YES ','{% if "foo" %} YES {% endif %}')
    assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => true})
    assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => "text"})
    assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => 1 })
    assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => {} })
    assert_template_result(' YES ','{% if foo.bar %} YES {% endif %}', 'foo' => {'bar' => [] })
    
    assert_template_result(' YES ','{% if var %} NO {% else %} YES {% endif %}', 'var' => false)
    assert_template_result(' YES ','{% if var %} NO {% else %} YES {% endif %}', 'var' => nil)
    assert_template_result(' YES ','{% if var %} YES {% else %} NO {% endif %}', 'var' => true)
    assert_template_result(' YES ','{% if "foo" %} YES {% else %} NO {% endif %}', 'var' => "text")
    
    assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo' => {'bar' => false})
    assert_template_result(' YES ','{% if foo.bar %} YES {% else %} NO {% endif %}', 'foo' => {'bar' => true})
    assert_template_result(' YES ','{% if foo.bar %} YES {% else %} NO {% endif %}', 'foo' => {'bar' => "text"})
    assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo' => {'notbar' => true})
    assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'foo' => {})
    assert_template_result(' YES ','{% if foo.bar %} NO {% else %} YES {% endif %}', 'notfoo' => {'bar' => true})
  end
  
  def test_nested_if
    assert_template_result('', '{% if false %}{% if false %} NO {% endif %}{% endif %}')
    assert_template_result('', '{% if false %}{% if true %} NO {% endif %}{% endif %}')
    assert_template_result('', '{% if true %}{% if false %} NO {% endif %}{% endif %}')
    assert_template_result(' YES ', '{% if true %}{% if true %} YES {% endif %}{% endif %}')
    
    assert_template_result(' YES ', '{% if true %}{% if true %} YES {% else %} NO {% endif %}{% else %} NO {% endif %}')
    assert_template_result(' YES ', '{% if true %}{% if false %} NO {% else %} YES {% endif %}{% else %} NO {% endif %}')
    assert_template_result(' YES ', '{% if false %}{% if true %} NO {% else %} NONO {% endif %}{% else %} YES {% endif %}')
    
  end
  
  def test_comparisons_on_null
    assert_template_result('','{% if null < 10 %} NO {% endif %}')
    assert_template_result('','{% if null <= 10 %} NO {% endif %}')
    assert_template_result('','{% if null >= 10 %} NO {% endif %}')
    assert_template_result('','{% if null > 10 %} NO {% endif %}')

    assert_template_result('','{% if 10 < null %} NO {% endif %}')
    assert_template_result('','{% if 10 <= null %} NO {% endif %}')
    assert_template_result('','{% if 10 >= null %} NO {% endif %}')
    assert_template_result('','{% if 10 > null %} NO {% endif %}')
  end
  
  def test_else_if
    assert_template_result('0','{% if 0 == 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}')
    assert_template_result('1','{% if 0 != 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}')
    assert_template_result('2','{% if 0 != 0 %}0{% elsif 1 != 1%}1{% else %}2{% endif %}')
    
    assert_template_result('elsif','{% if false %}if{% elsif true %}elsif{% endif %}')    
  end
  
  def test_syntax_error_no_variable
    assert_raise(SyntaxError){ assert_template_result('', '{% if jerry == 1 %}')}
  end
  
  def test_if_with_custom_condition
    Condition.operators['contains'] = :[]
    
    assert_template_result('yes', %({% if 'bob' contains 'o' %}yes{% endif %}))
    assert_template_result('no', %({% if 'bob' contains 'f' %}yes{% else %}no{% endif %}))
  ensure
    Condition.operators.delete 'contains'
  end
end