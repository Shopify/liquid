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

    def test_render_inline_snippet_without_outside_context
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

    def test_render_inline_snippet_with_outside_context
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, ..., message: 'Welcome!' %}
      LIQUID
      expected = <<~OUTPUT






        <div class="header header--dark">
          Welcome!
        </div>
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

        {% render header, ..., message: 'Welcome!' %}

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

    def test_render_inline_snippet_with_correct_argument_precedence
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign message = 'Goodbye!' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, message: 'Welcome!', ... %}
      LIQUID
      expected = <<~OUTPUT







        <div class="header header--dark">
          Goodbye!
        </div>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_correct_argument_order
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign message = 'Goodbye!' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header,  ..., message: 'Welcome!' %}
      LIQUID
      expected = <<~OUTPUT







        <div class="header header--dark">
          Welcome!
        </div>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_correct_duplicate_argument_precedence
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign message = 'Goodbye!' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, message: 'Welcome!', ..., message: 'Hi!' %}
      LIQUID
      expected = <<~OUTPUT







        <div class="header header--dark">
          Hi!
        </div>
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_inline_snippet_with_spread_hash
      template = <<~LIQUID.strip
        {% snippet header %}
        <div>
          {{ word }} {{ number }}
        </div>
        {% endsnippet %}

        {% render header, ...details %}
      LIQUID

      expected = <<~OUTPUT



        <div>
          potato 5
        </div>
      OUTPUT

      assert_template_result(expected, template, { 'details' => { 'word' => 'potato', 'number' => 5 } })
    end

    def test_render_inline_snippet_with_spread_drop
      product_drop = Class.new(Liquid::Drop) do
        def title
          'Cool Product'
        end

        def price
          99
        end

        def vendor
          'Acme'
        end
      end

      template = <<~LIQUID.strip
        {% snippet card %}
        <div>
          {{ title }} - ${{ price }} by {{ vendor }}
        </div>
        {% endsnippet %}

        {% render card, ...product %}
      LIQUID

      expected = <<~OUTPUT



        <div>
          Cool Product - $99 by Acme
        </div>
      OUTPUT

      assert_template_result(expected, template, { 'product' => product_drop.new })
    end

    def test_render_inline_snippet_with_overwritten_spread_drop
      product_drop = Class.new(Liquid::Drop) do
        def title
          'Cool Product'
        end

        def price
          99
        end

        def vendor
          'Acme'
        end
      end

      template = <<~LIQUID.strip
        {% snippet card %}
        <div>
          {{ title }} - ${{ price }} by {{ vendor }}
        </div>
        {% endsnippet %}

        {% render card, ...product, price: 10 %}
      LIQUID

      expected = <<~OUTPUT



        <div>
          Cool Product - $10 by Acme
        </div>
      OUTPUT

      assert_template_result(expected, template, { 'product' => product_drop.new })
    end

    def test_render_inline_snippet_spread_before_explicit_args
      template = <<~LIQUID.strip
        {% snippet card %}
        <div>{{ price }}</div>
        {% endsnippet %}

        {% render card, ...details, price: 10 %}
      LIQUID

      expected = <<~OUTPUT



        <div>10</div>
      OUTPUT

      assert_template_result(expected, template, { 'details' => { 'price' => 99 } })
    end

    def test_render_inline_snippet_multiple_spreads
      product_drop = Class.new(Liquid::Drop) do
        def title
          'Cool Product'
        end
      end

      template = <<~LIQUID.strip
        {% snippet card %}
        <div>{{ title }} - {{ price }} {{ color }}</div>
        {% endsnippet %}

        {% render card, ...defaults, ...product %}
      LIQUID

      expected = <<~OUTPUT



        <div>Cool Product - 10 </div>
      OUTPUT

      assert_template_result(
        expected,
        template,
        {
          'defaults' => { 'title' => 'Default', 'price' => 10 },
          'product' => product_drop.new,
        },
      )
    end

    def test_render_captured_snippet
      template = <<~LIQUID
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}

        {% capture up_header %}
        {%- render header, ..., message: 'Welcome!' -%}
        {% endcapture %}

        {{ up_header | upcase }}

        {{ header | upcase }}

        {{ header }}
      LIQUID
      expected = <<~OUTPUT







        <DIV CLASS="HEADER HEADER--DARK">
          WELCOME!
        </DIV>


        SNIPPETDROP

        SnippetDrop
      OUTPUT

      assert_template_result(expected, template)
    end

    def test_render_snippets_as_arguments
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
          <div class="header header--{{ color_scheme }}">
            {{ message }}
          </div>
        {% endsnippet %}

        {% snippet main %}
        {% assign color_scheme = 'auto' %}

        <div class="main main--{{ color_scheme }}">
        {% render header, ..., message: 'Welcome!' %}
        </div>
        {% endsnippet %}

        {% render main, header: header %}
      LIQUID

      expected = <<~OUTPUT









        <div class="main main--auto">

          <div class="header header--auto">
            Welcome!
          </div>

        </div>
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

    def test_render_inline_snippet_inside_loop
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign array = '1,2,3' | split: ',' %}

        {% for i in array %}
        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }} {{ i }}
        </div>
        {% endsnippet %}
        {% endfor %}

        {% render header, ..., message: '👉' %}
      LIQUID
      expected = <<~OUTPUT






        <div class="header header--dark">
          👉#{" "}
        </div>
      OUTPUT

      assert_template_result(expected, template)
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

    def test_render_inline_snippet_without_outside_context
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

    def test_render_inline_snippet_with_outside_context
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, ..., message: 'Welcome!' %}
      LIQUID
      expected = <<~OUTPUT






        <div class="header header--dark">
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

        {% render header, ..., message: 'Welcome!' %}

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

    def test_render_inline_snippet_with_correct_argument_precedence
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign message = 'Goodbye!' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, message: 'Welcome!', ... %}
      LIQUID
      expected = <<~OUTPUT







        <div class="header header--dark">
          Goodbye!
        </div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_correct_argument_order
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign message = 'Goodbye!' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, ..., message: 'Welcome!' %}
      LIQUID
      expected = <<~OUTPUT







        <div class="header header--dark">
          Welcome!
        </div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_correct_duplicate_argument_precedence
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign message = 'Goodbye!' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}


        {% render header, message: 'Welcome!', ..., message: 'Hi!' %}
      LIQUID
      expected = <<~OUTPUT







        <div class="header header--dark">
          Hi!
        </div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_spread_drop
      product_drop = Class.new(Liquid::Drop) do
        def title
          'Cool Product'
        end

        def price
          99
        end

        def vendor
          'Acme'
        end
      end

      template = <<~LIQUID.strip
        {% snippet card %}
        <div>
          {{ title }} - ${{ price }} by {{ vendor }}
        </div>
        {% endsnippet %}

        {% render card, ...product %}
      LIQUID

      expected = <<~OUTPUT



        <div>
          Cool Product - $99 by Acme
        </div>
      OUTPUT

      assert_template_result(expected, template, { 'product' => product_drop.new }, error_mode: :rigid)
    end

    def test_render_inline_snippet_with_overwritten_spread_drop
      product_drop = Class.new(Liquid::Drop) do
        def title
          'Cool Product'
        end

        def price
          99
        end

        def vendor
          'Acme'
        end
      end

      template = <<~LIQUID.strip
        {% snippet card %}
        <div>
          {{ title }} - ${{ price }} by {{ vendor }}
        </div>
        {% endsnippet %}

        {% render card, ...product, price: 10 %}
      LIQUID

      expected = <<~OUTPUT



        <div>
          Cool Product - $10 by Acme
        </div>
      OUTPUT

      assert_template_result(expected, template, { 'product' => product_drop.new }, error_mode: :rigid)
    end

    def test_render_inline_snippet_spread_before_explicit_args
      template = <<~LIQUID.strip
        {% snippet card %}
        <div>{{ price }}</div>
        {% endsnippet %}

        {% render card, ...details, price: 10 %}
      LIQUID

      expected = <<~OUTPUT



        <div>10</div>
      OUTPUT

      assert_template_result(expected, template, { 'details' => { 'price' => 99 } }, error_mode: :rigid)
    end

    def test_render_inline_snippet_multiple_spreads
      product_drop = Class.new(Liquid::Drop) do
        def title
          'Cool Product'
        end
      end

      template = <<~LIQUID.strip
        {% snippet card %}
        <div>{{ title }} - {{ price }} {{ color }}</div>
        {% endsnippet %}

        {% render card, ...defaults, ...product %}
      LIQUID

      expected = <<~OUTPUT



        <div>Cool Product - 10 </div>
      OUTPUT

      assert_template_result(
        expected,
        template,
        {
          'defaults' => { 'title' => 'Default', 'price' => 10 },
          'product' => product_drop.new,
        },
        error_mode: :rigid,
      )
    end

    def test_render_captured_snippet
      template = <<~LIQUID
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }}
        </div>
        {% endsnippet %}

        {% capture up_header %}
        {%- render header, ..., message: 'Welcome!' -%}
        {% endcapture %}

        {{ up_header | upcase }}

        {{ header | upcase }}

        {{ header }}
      LIQUID
      expected = <<~OUTPUT







        <DIV CLASS="HEADER HEADER--DARK">
          WELCOME!
        </DIV>


        SNIPPETDROP

        SnippetDrop
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
    end

    def test_render_snippets_as_arguments
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}

        {% snippet header %}
          <div class="header header--{{ color_scheme }}">
            {{ message }}
          </div>
        {% endsnippet %}

        {% snippet main %}
        {% assign color_scheme = 'auto' %}

        <div class="main main--{{ color_scheme }}">
        {% render header, ..., message: 'Welcome!' %}
        </div>
        {% endsnippet %}

        {% render main, header: header %}
      LIQUID

      expected = <<~OUTPUT









        <div class="main main--auto">

          <div class="header header--auto">
            Welcome!
          </div>

        </div>
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

    def test_render_inline_snippet_inside_loop
      template = <<~LIQUID.strip
        {% assign color_scheme = 'dark' %}
        {% assign array = '1,2,3' | split: ',' %}

        {% for i in array %}
        {% snippet header %}
        <div class="header header--{{ color_scheme }}">
          {{ message }} {{ i }}
        </div>
        {% endsnippet %}
        {% endfor %}

        {% render header, ..., message: '👉' %}
      LIQUID
      expected = <<~OUTPUT






        <div class="header header--dark">
          👉#{" "}
        </div>
      OUTPUT

      assert_template_result(expected, template, error_mode: :rigid)
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
