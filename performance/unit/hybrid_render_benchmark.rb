# frozen_string_literal: true

require "benchmark/ips"

# Benchmark hybrid render tag parsing overhead.

require 'liquid'

RubyVM::YJIT.enable if defined?(RubyVM::YJIT)

# -- Templates -----------------------------------------------------------------

SINGLE_SELF_CLOSING = "{% render 'snippet' %}"

MULTIPLE_SELF_CLOSING = (1..20).map { |i| "{% render 'snippet_#{i}' %}" }.join("\n")

BLOCK_FORM = "{% render 'snippet' %}Hello, world!{% endrender %}"

BLOCK_FORM_20X = (1..20).map { |i| "{% render 'snippet_#{i}' %}content #{i}{% endrender %}" }.join("\n")

MIXED_TEMPLATE = <<~LIQUID
  {% assign title = 'Hello' %}
  {% render 'header' %}
  {% for item in collection %}
    {% render 'card' %}
    <p>{{ item.title }}</p>
  {% endfor %}
  {% render 'footer' %}
LIQUID

LONG_TAIL = "{% render 'snippet' %}\n" + (1..100).map { |i| "{% assign x#{i} = #{i} %}" }.join("\n")

NESTED_CONDITIONALS = <<~LIQUID
  {% if customer %}
    {% if customer.name %}
      <h1>{{ customer.name }}</h1>
    {% else %}
      <h1>Guest</h1>
    {% endif %}
    {% if customer.vip %}
      <span class="badge">VIP</span>
    {% endif %}
  {% else %}
    {% if template == 'index' %}
      <h1>Welcome</h1>
    {% endif %}
  {% endif %}
LIQUID

LOOP_HEAVY = <<~LIQUID
  {% for product in collection.products %}
    <div class="product">
      <h2>{{ product.title }}</h2>
      <p>{{ product.price | money }}</p>
      {% if product.available %}
        <button>Add to cart</button>
      {% else %}
        <button disabled>Sold out</button>
      {% endif %}
    </div>
  {% endfor %}
  {% for tag in collection.tags %}
    <span class="tag">{{ tag }}</span>
  {% endfor %}
  {% if paginate.pages > 1 %}
    <nav>{{ paginate | default_pagination }}</nav>
  {% endif %}
LIQUID

CONTROL_FLOW_NO_RENDER = <<~LIQUID
  {% case template %}
    {% when 'product' %}
      {% for block in section.blocks %}
        {% if block.type == 'title' %}
          <h1>{{ product.title }}</h1>
        {% elsif block.type == 'price' %}
          <span>{{ product.price | money }}</span>
        {% elsif block.type == 'description' %}
          {{ product.description }}
        {% endif %}
      {% endfor %}
    {% when 'collection' %}
      {% for product in collection.products %}
        {% if product.available %}
          <div>{{ product.title }}</div>
        {% endif %}
      {% endfor %}
    {% when 'index' %}
      {% for section in page.sections %}
        {{ section.content }}
      {% endfor %}
  {% endcase %}
LIQUID

SINGLE_RENDER_AMONG_BLOCKS = <<~LIQUID
  {% if settings.show_header %}
    {% render 'header' %}
  {% endif %}
  {% for product in collection.products %}
    <div class="product">
      <h2>{{ product.title }}</h2>
      {% if product.compare_at_price > product.price %}
        <span class="sale">{{ product.compare_at_price | money }}</span>
      {% endif %}
      {% if product.available %}
        <button>Add to cart</button>
      {% else %}
        <span>Sold out</span>
      {% endif %}
    </div>
  {% endfor %}
  {% if paginate.pages > 1 %}
    <nav>{{ paginate | default_pagination }}</nav>
  {% endif %}
LIQUID

RENDER_AMONG_50_BLOCKS = begin
  opens = (1..25).map { |i| "#{"  " * i}{% if cond_#{i} %}" }.join("\n")
  closes = (1..25).map { |i| "#{"  " * (26 - i)}{% endif %}" }.join("\n")
  <<~LIQUID
    {% for item in collection %}
    #{opens}
    #{"  " * 26}{% render 'deep_snippet' %}
    #{closes}
    {% endfor %}
  LIQUID
end

INTERLEAVED_RENDERS_AND_BLOCKS = (1..20).map { |i| "{% if cond_#{i} %}\n  {% render 'snippet_#{i}' %}\n{% endif %}" }.join("\n")

TEMPLATES = {
  "single self-closing render" => SINGLE_SELF_CLOSING,
  "20x consecutive self-closing renders" => MULTIPLE_SELF_CLOSING,
  "block-form render" => BLOCK_FORM,
  "mixed template (self-closing + other tags)" => MIXED_TEMPLATE,
  "self-closing render + 100 trailing tags" => LONG_TAIL,
  "nested conditionals (0 renders, 6 end tags)" => NESTED_CONDITIONALS,
  "loop-heavy (0 renders, 5 end tags)" => LOOP_HEAVY,
  "control flow (0 renders, 10 end tags)" => CONTROL_FLOW_NO_RENDER,
  "1 render among blocks (1 render, 8 end tags)" => SINGLE_RENDER_AMONG_BLOCKS,
  "20x block-form renders (20 renders, 20 end tags)" => BLOCK_FORM_20X,
  "1 render among 50 nested blocks (1 render, 51 end tags)" => RENDER_AMONG_50_BLOCKS,
  "20 renders interleaved with blocks (20 renders, 20 end tags)" => INTERLEAVED_RENDERS_AND_BLOCKS,
}

# -- Benchmark -----------------------------------------------------------------

env = Liquid::Environment.default

Benchmark.ips do |x|
  x.config(time: 10, warmup: 5)

  TEMPLATES.each do |label, source|
    Liquid::Template.parse(source, environment: env)
    x.report("parse: #{label}") do
      Liquid::Template.parse(source, environment: env)
    end
  rescue Liquid::SyntaxError => e
    puts "  Skipping '#{label}' - #{e.message}"
  end

  x.compare!
end
