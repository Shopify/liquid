require 'test_helper'

class WhileTagTest < Minitest::Test
  include Liquid

  def test_while
    assert_template_result(' yo ', '{%while myval %} yo {%assign myval = false%}{%endwhile%}', 'myval' => true)
    assert_template_result('0123', '{%while myval %}{%increment myval %}{% if myval > 3 %}{% assign myval = false %}{%endif%}{%endwhile%}', 'myval' => 0)
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
