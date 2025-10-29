# frozen_string_literal: true

require 'test_helper'

class SnippetTest < Minitest::Test
  include Liquid

  class LaxMode < SnippetTest
    def test_valid_inline_snippet
      template = <<~LIQUID.strip
        {% snippet input %}
          Hey
        {% endsnippet %}
      LIQUID
      expected = ''

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet
      template = <<~LIQUID.strip
        {% snippet hey %}
        Hey
        {% endsnippet %}

        {%- render hey -%}
      LIQUID
      expected = <<~OUTPUT

        Hey
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_variable
      template = <<~LIQUID.strip
        {% snippet hey %}
        <p>Today is {{ "hello" | capitalize }}</p>
        {% endsnippet %}

        {%- render hey -%}
      LIQUID
      expected = <<~OUTPUT

        <p>Today is Hello</p>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_multiple_inline_snippets
      template = <<~LIQUID.strip
        {% snippet input %}
        <input />
        {% endsnippet %}

        {% snippet banner %}
        <marquee direction="up" height="100px">
          Welcome to my store!
        </marquee>
        {% endsnippet %}

        {%- render input -%}
        {%- render banner -%}
      LIQUID
      expected = <<~OUTPUT



        <input />

        <marquee direction="up" height="100px">
          Welcome to my store!
        </marquee>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_argument
      template = <<~LIQUID.strip
        {% snippet input %}
        <input type="{{ type }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
      LIQUID
      expected = <<~OUTPUT

        <input type="text" />
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_doc_tag
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc  %}
          @param {string} type - Input type.
        {% enddoc %}

        <input type="{{ type }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" />
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_evaluated_assign
      template = <<~LIQUID.strip
        {% snippet input %}
        <h1>{{ greeting }}</h1>
        {% endsnippet %}

        {%- assign greeting = "hello" | upcase -%}
        {%- render input, greeting: greeting  -%}
      LIQUID
      expected = <<~OUTPUT

        <h1>HELLO</h1>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_multiple_arguments
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
          @param {string} value - Input value.
        {% enddoc %}

        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text", value: "Hello" -%}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" value="Hello" />
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippets_using_same_argument_name
      template = <<~LIQUID.strip
        {% snippet input %}
        <input type="{{ type }}" />
        {% endsnippet %}

        {% snippet inputs %}
        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
        {%- render inputs, type: "password", value: "pass" -%}
      LIQUID

      expected = <<~OUTPUT



        <input type="text" />

        <input type="password" value="pass" />
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_empty_string_when_missing_argument
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
          @param {string} value - Input value.
        {% enddoc %}

        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" value="" />
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_snippets_as_arguments
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
          <div class="header">
            {{ message }}
          </div>
        {% endsnippet %}

        {% snippet main %}
        {% assign color_scheme = 'auto' %}

        <div class="main main--{{ color_scheme }}">
        {% render header, message: 'Welcome!' %}
        </div>
        {% endsnippet %}

        {% render main, header: header %}
      LIQUID

      expected = <<~OUTPUT









        <div class="main main--auto">

          <div class="header">
            Welcome!
          </div>

        </div>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_shouldnt_leak_context
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
          @param {string} value - Input value.
        {% enddoc %}

        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text", value: "Hello" -%}

        {{ type }}
        {{ value }}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" value="Hello" />

      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_multiple_inline_snippets_without_leaking_context
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
        {% enddoc %}

        <input type="{{ type }}" />
        {% endsnippet %}

        {% snippet no_leak %}
        <input type="{{ type }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
        {%- render no_leak -%}
      LIQUID
      expected = <<~OUTPUT





        <input type="text" />

        <input type="" />
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_ignores_outside_context
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, message: 'Welcome!' %}
      LIQUID
      expected = <<~OUTPUT






        <div class="header header--">
          Welcome!
        </div>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_captured_snippet
      template = <<~LIQUID
        {% snippet header %}
        <div class="header">
          {{ message }}
        </div>
        {% endsnippet %}

        {% capture up_header %}
        {%- render header, message: 'Welcome!' -%}
        {% endcapture %}

        {{ up_header | upcase }}

        {{ header | upcase }}

        {{ header }}
      LIQUID
      expected = <<~OUTPUT





        <DIV CLASS="HEADER">
          WELCOME!
        </DIV>


        SNIPPETDROP

        SnippetDrop
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_inline_snippet_local_scope_takes_precedence
      template = <<~LIQUID
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        {% assign color_scheme = 'light' %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}

        {{ color_scheme }}

        {% render header,  message: 'Welcome!', color_scheme: color_scheme %}

        {{ color_scheme }}
      LIQUID
      expected = <<~OUTPUT




        dark



        <div class="header header--light">
          Welcome!
        </div>


        dark
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_forloop
      template = <<~LIQUID.strip
        {% snippet item %}
        <li>{{ forloop.index }}: {{ item }}</li>
        {% endsnippet %}

        {% assign items = "A,B,C" | split: "," %}
        {%- render item for items -%}
      LIQUID
      expected = <<~OUTPUT



        <li>1: A</li>

        <li>2: B</li>

        <li>3: C</li>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with
      template = <<~LIQUID.strip
        {% snippet header %}
        <div>{{ header }}</div>
        {% endsnippet %}

        {% assign product = "Apple" %}
        {%- render header with product -%}
      LIQUID
      expected = <<~OUTPUT



        <div>Apple</div>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_alias
      template = <<~LIQUID.strip
        {% snippet product_card %}
        <div class="product">{{ item }}</div>
        {% endsnippet %}

        {% assign featured = "Apple" %}
        {%- render product_card with featured as item -%}
      LIQUID
      expected = <<~OUTPUT



        <div class="product">Apple</div>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_snippet_with_invalid_identifier
      template = <<~LIQUID
        {% snippet header foo bar %}
          Invalid
        {% endsnippet %}
      LIQUID

      exception = assert_raises(SyntaxError) { Liquid::Template.parse(template) }

      assert_match("Expected end_of_string but found id", exception.message)
    end

    def test_render_with_non_existent_tag
      template = Liquid::Template.parse(<<~LIQUID.chomp, line_numbers: true)
        {% snippet foo %}
        {% render non_existent %}
        {% endsnippet %}

        {% render foo %}
      LIQUID

      expected = <<~TEXT



        Liquid error (index line 2): This liquid context does not allow includes
      TEXT
      template.name = "index"

      assert_equal(expected, template.render('errors' => ErrorDrop.new))
    end

    def test_render_handles_errors
      template = Liquid::Template.parse(<<~LIQUID.chomp, line_numbers: true)
        {% snippet foo %}
        {% render non_existent %} will raise an error.

        Bla bla test.

        This is an argument error: {{ 'test' | slice: 'not a number' }}
        {% endsnippet %}

        {% render foo %}
      LIQUID

      expected = <<~TEXT



        Liquid error (index line 2): This liquid context does not allow includes will raise an error.

        Bla bla test.

        This is an argument error: Liquid error (index line 6): invalid integer
      TEXT
      template.name = "index"

      assert_equal(expected, template.render('errors' => ErrorDrop.new))
    end
  end

  class RigidMode < SnippetTest
    def test_valid_inline_snippet
      template = <<~LIQUID.strip
        {% snippet input %}
          Hey
        {% endsnippet %}
      LIQUID
      expected = ''

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet
      template = <<~LIQUID.strip
        {% snippet hey %}
        Hey
        {% endsnippet %}

        {%- render hey -%}
      LIQUID
      expected = <<~OUTPUT

        Hey
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_variable
      template = <<~LIQUID.strip
        {% snippet hey %}
        <p>Today is {{ "hello" | capitalize }}</p>
        {% endsnippet %}

        {%- render hey -%}
      LIQUID
      expected = <<~OUTPUT

        <p>Today is Hello</p>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_multiple_inline_snippets
      template = <<~LIQUID.strip
        {% snippet input %}
        <input />
        {% endsnippet %}

        {% snippet banner %}
        <marquee direction="up" height="100px">
          Welcome to my store!
        </marquee>
        {% endsnippet %}

        {%- render input -%}
        {%- render banner -%}
      LIQUID
      expected = <<~OUTPUT



        <input />

        <marquee direction="up" height="100px">
          Welcome to my store!
        </marquee>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_argument
      template = <<~LIQUID.strip
        {% snippet input %}
        <input type="{{ type }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
      LIQUID
      expected = <<~OUTPUT

        <input type="text" />
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_doc_tag
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc  %}
          @param {string} type - Input type.
        {% enddoc %}

        <input type="{{ type }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" />
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_evaluated_assign
      template = <<~LIQUID.strip
        {% snippet input %}
        <h1>{{ greeting }}</h1>
        {% endsnippet %}

        {%- assign greeting = "hello" | upcase -%}
        {%- render input, greeting: greeting  -%}
      LIQUID
      expected = <<~OUTPUT

        <h1>HELLO</h1>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_multiple_arguments
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
          @param {string} value - Input value.
        {% enddoc %}

        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text", value: "Hello" -%}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" value="Hello" />
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippets_using_same_argument_name
      template = <<~LIQUID.strip
        {% snippet input %}
        <input type="{{ type }}" />
        {% endsnippet %}

        {% snippet inputs %}
        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
        {%- render inputs, type: "password", value: "pass" -%}
      LIQUID

      expected = <<~OUTPUT



        <input type="text" />

        <input type="password" value="pass" />
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_empty_string_when_missing_argument
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
          @param {string} value - Input value.
        {% enddoc %}

        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" value="" />
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_snippets_as_arguments
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
          <div class="header">
            {{ message }}
          </div>
        {% endsnippet %}

        {% snippet main %}
        {% assign color_scheme = 'auto' %}

        <div class="main main--{{ color_scheme }}">
        {% render header, message: 'Welcome!' %}
        </div>
        {% endsnippet %}

        {% render main, header: header %}
      LIQUID

      expected = <<~OUTPUT









        <div class="main main--auto">

          <div class="header">
            Welcome!
          </div>

        </div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_shouldnt_leak_context
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
          @param {string} value - Input value.
        {% enddoc %}

        <input type="{{ type }}" value="{{ value }}" />
        {% endsnippet %}

        {%- render input, type: "text", value: "Hello" -%}

        {{ type }}
        {{ value }}
      LIQUID
      expected = <<~OUTPUT



        <input type="text" value="Hello" />

      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_multiple_inline_snippets_without_leaking_context
      template = <<~LIQUID.strip
        {% snippet input %}
        {% doc %}
          @param {string} type - Input type.
        {% enddoc %}

        <input type="{{ type }}" />
        {% endsnippet %}

        {% snippet no_leak %}
        <input type="{{ type }}" />
        {% endsnippet %}

        {%- render input, type: "text" -%}
        {%- render no_leak -%}
      LIQUID
      expected = <<~OUTPUT





        <input type="text" />

        <input type="" />
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_ignores_outside_context
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, message: 'Welcome!' %}
      LIQUID
      expected = <<~OUTPUT






        <div class="header header--">
          Welcome!
        </div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_inline_snippet_local_scope_takes_precedence
      template = <<~LIQUID
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        {% assign color_scheme = 'light' %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}

        {{ color_scheme }}

        {% render header,  message: 'Welcome!', color_scheme: color_scheme %}

        {{ color_scheme }}
      LIQUID
      expected = <<~OUTPUT




        dark



        <div class="header header--light">
          Welcome!
        </div>


        dark
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_forloop
      template = <<~LIQUID.strip
        {% snippet item %}
        <li>{{ forloop.index }}: {{ item }}</li>
        {% endsnippet %}

        {% assign items = "A,B,C" | split: "," %}
        {%- render item for items -%}
      LIQUID
      expected = <<~OUTPUT



        <li>1: A</li>

        <li>2: B</li>

        <li>3: C</li>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with
      template = <<~LIQUID.strip
        {% snippet header %}
        <div>{{ header }}</div>
        {% endsnippet %}

        {% assign product = "Apple" %}
        {%- render header with product -%}
      LIQUID
      expected = <<~OUTPUT



        <div>Apple</div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_alias
      template = <<~LIQUID.strip
        {% snippet product_card %}
        <div class="product">{{ item }}</div>
        {% endsnippet %}

        {% assign featured = "Apple" %}
        {%- render product_card with featured as item -%}
      LIQUID
      expected = <<~OUTPUT



        <div class="product">Apple</div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_captured_snippet
      template = <<~LIQUID
        {% snippet header %}
        <div class="header">
          {{ message }}
        </div>
        {% endsnippet %}

        {% capture up_header %}
        {%- render header, message: 'Welcome!' -%}
        {% endcapture %}

        {{ up_header | upcase }}

        {{ header | upcase }}

        {{ header }}
      LIQUID
      expected = <<~OUTPUT





        <DIV CLASS="HEADER">
          WELCOME!
        </DIV>


        SNIPPETDROP

        SnippetDrop
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_with_invalid_identifier
      template = "{% render 123 %}"

      exception = assert_raises(SyntaxError) do
        Liquid::Template.parse(template, error_mode: :rigid)
      end

      assert_match("Expected a string or identifier, found 123", exception.message)
    end

    def test_render_with_non_existent_tag
      template = Liquid::Template.parse(<<~LIQUID.chomp, line_numbers: true, error_mode: :rigid)
        {% snippet foo %}
        {% render non_existent %}
        {% endsnippet %}

        {% render foo %}
      LIQUID

      expected = <<~TEXT



        Liquid error (index line 2): This liquid context does not allow includes
      TEXT
      template.name = "index"

      assert_equal(expected, template.render('errors' => ErrorDrop.new))
    end

    def test_render_handles_errors
      template = Liquid::Template.parse(<<~LIQUID.chomp, line_numbers: true, error_mode: :rigid)
        {% snippet foo %}
        {% render non_existent %} will raise an error.

        Bla bla test.

        This is an argument error: {{ 'test' | slice: 'not a number' }}
        {% endsnippet %}

        {% render foo %}
      LIQUID

      expected = <<~TEXT



        Liquid error (index line 2): This liquid context does not allow includes will raise an error.

        Bla bla test.

        This is an argument error: Liquid error (index line 6): invalid integer
      TEXT
      template.name = "index"

      assert_equal(expected, template.render('errors' => ErrorDrop.new))
    end

    def test_render_with_no_identifier
      template = "{% render %}"

      exception = assert_raises(SyntaxError) do
        Liquid::Template.parse(template, error_mode: :rigid)
      end

      assert_match("Expected a string or identifier, found nothing", exception.message)
    end

    def test_snippet_with_invalid_identifier
      template = <<~LIQUID
        {% snippet header foo bar %}
          Invalid
        {% endsnippet %}
      LIQUID

      exception = assert_raises(SyntaxError) do
        Liquid::Template.parse(template, error_mode: :rigid)
      end

      assert_match("Expected end_of_string but found id", exception.message)
    end
  end

  class ResourceLimits < SnippetTest
    def test_increment_assign_score_by_bytes_not_characters
      t = Template.parse("{% snippet foo %}すごい{% endsnippet %}")
      t.render!
      assert_equal(9, t.resource_limits.assign_score)
    end
  end
end
