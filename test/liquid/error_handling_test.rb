require 'test_helper'

class ErrorDrop < Liquid::Drop
  def standard_error
    raise Liquid::StandardError, 'standard error'
  end

  def argument_error
    raise Liquid::ArgumentError, 'argument error'
  end

  def syntax_error
    raise Liquid::SyntaxError, 'syntax error'
  end

  def exception
    raise Exception, 'exception'
  end

end

class ErrorHandlingTest < Test::Unit::TestCase
  include Liquid

  def test_standard_error
    assert_nothing_raised do
      template = Liquid::Template.parse( ' {{ errors.standard_error }} '  )
      assert_equal ' Liquid error: standard error ', template.render('errors' => ErrorDrop.new)

      assert_equal 1, template.errors.size
      assert_equal StandardError, template.errors.first.class
    end
  end

  def test_syntax

    assert_nothing_raised do

      template = Liquid::Template.parse( ' {{ errors.syntax_error }} '  )
      assert_equal ' Liquid syntax error: syntax error ', template.render('errors' => ErrorDrop.new)

      assert_equal 1, template.errors.size
      assert_equal SyntaxError, template.errors.first.class

    end
  end

  def test_argument
    assert_nothing_raised do

      template = Liquid::Template.parse( ' {{ errors.argument_error }} '  )
      assert_equal ' Liquid error: argument error ', template.render('errors' => ErrorDrop.new)

      assert_equal 1, template.errors.size
      assert_equal ArgumentError, template.errors.first.class
    end
  end

  def test_missing_endtag_parse_time_error
    assert_raise(Liquid::SyntaxError) do
      Liquid::Template.parse(' {% for a in b %} ... ')
    end
  end

  def test_unrecognized_operator
    with_error_mode(:strict) do
      assert_raise(SyntaxError) do
        Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ')
      end
    end
  end
  
  def test_lax_unrecognized_operator
    assert_nothing_raised do
      template = Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ', :error_mode => :lax)
      assert_equal ' Liquid error: Unknown operator =! ', template.render
      assert_equal 1, template.errors.size
      assert_equal Liquid::ArgumentError, template.errors.first.class
    end
  end

  def test_strict_error_messages
    err = assert_raise(SyntaxError) do
      Liquid::Template.parse(' {% if 1 =! 2 %}ok{% endif %} ', :error_mode => :strict)
    end
    assert_equal 'Unexpected character = in "1 =! 2"', err.message

    err = assert_raise(SyntaxError) do
      Liquid::Template.parse('{{%%%}}', :error_mode => :strict)
    end
    assert_equal 'Unexpected character % in "{{%%%}}"', err.message
  end

  def test_warnings
    template = Liquid::Template.parse('{% if ~~~ %}{{%%%}}{% else %}{{ hello. }}{% endif %}', :error_mode => :warn)
    assert_equal 3, template.warnings.size
    assert_equal 'Unexpected character ~ in "~~~"', template.warnings[0].message
    assert_equal 'Unexpected character % in "{{%%%}}"', template.warnings[1].message
    assert_equal 'Expected id but found [:end_of_string] in "{{ hello. }}"', template.warnings[2].message
    assert_equal '', template.render
  end

  # Liquid should not catch Exceptions that are not subclasses of StandardError, like Interrupt and NoMemoryError
  def test_exceptions_propagate
    assert_raise Exception do
      template = Liquid::Template.parse( ' {{ errors.exception }} '  )
      template.render('errors' => ErrorDrop.new)
    end
  end
end # ErrorHandlingTest
