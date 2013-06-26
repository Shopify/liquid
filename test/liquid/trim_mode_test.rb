require 'test_helper'

class TrimModeTest < Test::Unit::TestCase
  include Liquid

  # Make sure the trim isn't applied to standard output
  def test_standard_output
    assert_template_result("
      <div>
        <p>
          John
        </p>
      </div>", "
      <div>
        <p>
          {{ name }}
        </p>
      </div>",
      'name' => 'John')
  end

  # Make sure the trim isn't applied to standard tags
  def test_standard_tags
    assert_template_result("
      <div>
        <p>
          
          yes
          
        </p>
      </div>", "
      <div>
        <p>
          {% if test %}
          yes
          {% endif %}
        </p>
      </div>",
      'test' => true)
    assert_template_result("
      <div>
        <p>
          
        </p>
      </div>", "
      <div>
        <p>
          {% if test %}
          no
          {% endif %}
        </p>
      </div>",
      'test' => false)
  end

  # Make sure the trim isn't too agressive
  def test_no_trim_output
    assert_template_result("<p>John</p>", "<p>{{- name -}}</p>", 'name' => 'John')
  end

  # Make sure the trim isn't too agressive
  def test_no_trim_tags
    assert_template_result("<p>yes</p>", "<p>{%- if test -%}yes{%- endif -%}</p>", 'test' => true)
    assert_template_result("<p></p>", "<p>{%- if test -%}no{%- endif -%}</p>", 'test' => false)
  end

  def test_pre_trim_output
    assert_template_result("
      <div>
        <p>John
        </p>
      </div>", "
      <div>
        <p>
          {{- name }}
        </p>
      </div>",
      'name' => 'John')
  end

  def test_pre_trim_tags
    assert_template_result("
      <div>
        <p>

          yes

        </p>
      </div>", "
      <div>
        <p>
          {%- if test %}
          yes
          {%- endif %}
        </p>
      </div>",
      'test' => true)
    assert_template_result("
      <div>
        <p>

        </p>
      </div>", "
      <div>
        <p>
          {%- if test %}
          no
          {%- endif %}
        </p>
      </div>",
      'test' => false)
  end

  def test_post_trim_output
    assert_template_result("
      <div>
        <p>
          John</p>
      </div>", "
      <div>
        <p>
          {{ name -}}
        </p>
      </div>",
      'name' => 'John')
  end

  def test_post_trim_tags
    assert_template_result("
      <div>
        <p>
                    yes
                  </p>
      </div>", "
      <div>
        <p>
          {% if test -%}
          yes
          {% endif -%}
        </p>
      </div>",
      'test' => true)
    assert_template_result("
      <div>
        <p>
                  </p>
      </div>", "
      <div>
        <p>
          {% if test -%}
          no
          {% endif -%}
        </p>
      </div>",
      'test' => false)
  end

  def test_trim_output
    assert_template_result("
      <div>
        <p>John</p>
      </div>", "
      <div>
        <p>
          {{- name -}}
        </p>
      </div>",
      'name' => 'John')
  end

  def test_trim_tags
    assert_template_result("
      <div>
        <p>
          yes
        </p>
      </div>", "
      <div>
        <p>
          {%- if test -%}
          yes
          {%- endif -%}
        </p>
      </div>",
      'test' => true)
    assert_template_result("
      <div>
        <p>
        </p>
      </div>", "
      <div>
        <p>
          {%- if test -%}
          no
          {%- endif -%}
        </p>
      </div>",
      'test' => false)
  end

  def test_complex_trim_output
    assert_template_result("
      <div>
        <p>John30</p>
        <b>
          John30
        </b>
        <i>John
          30</i>
      </div>", "
      <div>
        <p>
          {{- name -}}
          {{- age -}}
        </p>
        <b>
          {{ name -}}
          {{- age }}
        </b>
        <i>
          {{- name }}
          {{ age -}}
        </i>
      </div>",
      'name' => 'John', 'age' => 30)
  end

  def test_complex_trim
    assert_template_result("
      <div>
            <p>John</p>
      </div>", "
      <div>
        {%- if test -%}
          {%- if another -%}
            <p>
              {{- name -}}
            </p>
          {%- endif -%}
        {%- endif -%}
      </div>",
      'test' => true, 'another' => true, 'name' => 'John')
  end
end # TrimModeTest
