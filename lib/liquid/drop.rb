require 'set'

module Liquid

  # A drop in liquid is a class which allows you to export DOM like things to liquid.
  # Methods of drops are callable.
  # The main use for liquid drops is to implement lazy loaded objects.
  # If you would like to make data available to the web designers which you don't want loaded unless needed then
  # a drop is a great way to do that.
  #
  # Example:
  #
  #   class ProductDrop < Liquid::Drop
  #     def top_sales
  #       Shop.current.products.find(:all, :order => 'sales', :limit => 10 )
  #     end
  #   end
  #
  #   tmpl = Liquid::Template.parse( ' {% for product in product.top_sales %} {{ product.name }} {%endfor%} '  )
  #   tmpl.render('product' => ProductDrop.new ) # will invoke top_sales query.
  #
  # Your drop can either implement the methods sans any parameters or implement the before_method(name) method which is a
  # catch all.
  class Drop
    attr_writer :context

    EMPTY_STRING = ''.freeze

    # Catch all for the method
    def before_method(method)
      nil
    end

    # called by liquid to invoke a drop
    def invoke_drop(method_or_key)
      if method_or_key && method_or_key != EMPTY_STRING && self.class.invokable?(method_or_key)
        send(method_or_key)
      else
        before_method(method_or_key)
      end
    end

    def has_key?(name)
      true
    end

    def inspect
      self.class.to_s
    end

    def to_liquid
      self
    end

    def to_s
      self.class.name
    end

    alias :[] :invoke_drop

    private

    # Check for method existence without invoking respond_to?, which creates symbols
    def self.invokable?(method_name)
      unless @invokable_methods
        blacklist = Liquid::Drop.public_instance_methods + [:each]
        if include?(Enumerable)
          blacklist += Enumerable.public_instance_methods
          blacklist -= [:sort, :count, :first, :min, :max, :include?]
        end
        whitelist = [:to_liquid] + (public_instance_methods - blacklist)
        @invokable_methods = Set.new(whitelist.map(&:to_s))
      end
      @invokable_methods.include?(method_name.to_s)
    end
  end
end
