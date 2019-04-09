require 'test_helper'

class WhileTagTest < Minitest::Test
  include Liquid

  def test_while
    # test value to be truthy/falsy
    assert_template_result(' yo ', '{%while myval %} yo {%assign myval = false%}{%endwhile%}', 'myval' => true)
    assert_template_result(' yo ', '{%while myval %} yo {%assign myval = false%}{%endwhile%}', 'myval' => 0)
    assert_template_result(' yo ', '{%while myval %} yo {%assign myval = false%}{%endwhile%}', 'myval' => 'test')
    assert_template_result('', '{%while myval %} yo {%assign myval = true%}{%endwhile%}', 'myval' => false)
    assert_template_result('', '{%while myval %} yo {%assign myval = true%}{%endwhile%}', 'myval' => nil)

    assert_template_result('0123', '{%while myval %}{%increment counter %}{% if counter > 3 %}{% assign myval = false %}{%endif%}{%endwhile%}', 'myval' => true)

    # test and/or
    assert_template_result(' yo ', '{%while myval1 or myval2 %} yo {%assign myval1 = false%}{%endwhile%}', 'myval1' => true, 'myval2' => false)
    assert_template_result('', '{%while myval1 and myval2 %} yo {%endwhile%}', 'myval1' => true, 'myval2' => false)

    # test binary comparators ==, !=, <, <=, >, >= with constants and with two variables
    # test ==
    assert_template_result('0', '{%while myval == 0 %}{{myval}}{%assign myval = myval | plus: 1 %}{%endwhile%}', 'myval' => 0)
    assert_template_result('0', '{%while myval1 == myval2 %}{{myval1}}{%assign myval1 = myval1 | plus: 1 %}{%endwhile%}', {'myval1' => 0, 'myval2' => 0})

    # test !=
    assert_template_result('0123', '{%while myval != 4 %}{{myval}}{%assign myval = myval | plus: 1 %}{%endwhile%}', 'myval' => 0)
    assert_template_result('0123', '{%while myval1 != myval2 %}{{myval1}}{%assign myval1 = myval1 | plus: 1 %}{%endwhile%}', {'myval1' => 0, 'myval2' => 4})

    # test <
    assert_template_result('0123', '{%while myval < 4 %}{{myval}}{%assign myval = myval | plus: 1 %}{%endwhile%}', 'myval' => 0)
    assert_template_result('0123', '{%while myval1 < myval2 %}{{myval1}}{%assign myval1 = myval1 | plus: 1 %}{%endwhile%}', {'myval1' => 0, 'myval2' => 4})

    # test <=
    assert_template_result('01234', '{%while myval <= 4 %}{{myval}}{%assign myval = myval | plus: 1 %}{%endwhile%}', 'myval' => 0)
    assert_template_result('01234', '{%while myval1 <= myval2 %}{{myval1}}{%assign myval1 = myval1 | plus: 1 %}{%endwhile%}', {'myval1' => 0, 'myval2' => 4})

    # test >
    assert_template_result('8765', '{%while myval > 4 %}{{myval}}{%assign myval = myval | minus: 1 %}{%endwhile%}', 'myval' => 8)
    assert_template_result('8765', '{%while myval1 > myval2 %}{{myval1}}{%assign myval1 = myval1 | minus: 1 %}{%endwhile%}', {'myval1' => 8, 'myval2' => 4})

    # test >=
    assert_template_result('87654', '{%while myval >= 4 %}{{myval}}{%assign myval = myval | minus: 1 %}{%endwhile%}', 'myval' => 8)
    assert_template_result('87654', '{%while myval1 >= myval2 %}{{myval1}}{%assign myval1 = myval1 | minus: 1 %}{%endwhile%}', {'myval1' => 8, 'myval2' => 4})

    # test compound expressions
    assert_template_result('', '{%while true and 3 > 4 %} yo {%endwhile%}')
    assert_template_result(' yo ', '{%while true and true or 3 > 4%} yo {%break%}{%endwhile%}')
  end

  def test_while_with_break
    assert_template_result('', '{%while true %}{% break %}{%endwhile%}')
    assert_template_result('0123', '{%while true %}{% increment counter %}{% if counter > 3 %}{% break %}{%endif%}{%endwhile%}')

    # tests to ensure it only breaks out of local while loop and not all of them
    assigns = {'counter1' => 0, 'counter2' => 0}
    markup = '{% while true %}' \
             ' outer{{counter1}} '\
               '{% assign counter1 = counter1 | plus: 1 %}'\
               '{% if counter1 > 3 %}'\
                 '{% break %}'\
               '{% endif %}'\
               '{% assign counter2 = 0 %}'\
               '{% while true %}'\
                 '{{ counter2 }}'\
                 '{% assign counter2 = counter2 | plus: 1 %}'\
                 '{% if counter2 > 3 %}'\
                   '{%break%}'\
                 '{%endif%}'\
               '{%endwhile%}'\
             '{%endwhile%}'
    expected = ' outer0 0123 outer1 0123 outer2 0123 outer3 '
    assert_template_result(expected,markup,assigns)
  end

  def test_while_with_continue
    assigns = {'counter' => 0}
    markup = '{% while true %}'\
               '{% assign counter = counter | plus: 1 %}'\
               '{% if counter < 3 %}'\
                 '{% continue %}'\
               '{% endif %}'\
               '{{ counter }}'\
               '{% if counter > 5 %}'\
                 '{% break %}'\
               '{% endif %}'\
             '{% endwhile %}'
    expected = '3456'
    assert_template_result(expected,markup,assigns)
  end

end
