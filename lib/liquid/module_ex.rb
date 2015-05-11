# Copyright 2007 by Domizio Demichelis
# This library is free software. It may be used, redistributed and/or modified
# under the same terms as Ruby itself
#
# This extension is used in order to expose the object of the implementing class
# to liquid as it were a Drop. It also limits the liquid-callable methods of the instance
# to the allowed method passed with the liquid_methods call
# Example:
#
#   class SomeClass
#     liquid_methods :an_allowed_method
#
#     def an_allowed_method
#       'this comes from an allowed method'
#     end
#
#     def unallowed_method
#       'this will never be an output'
#     end
#   end
#
# if you want to extend the drop to other methods you can defines more methods
# in the class <YourClass>::LiquidDropClass
#
#   class SomeClass::LiquidDropClass
#     def another_allowed_method
#       'and this from another allowed method'
#     end
#   end
#
#
# usage:
#   @something = SomeClass.new
#
# template:
#   {{something.an_allowed_method}}{{something.unallowed_method}} {{something.another_allowed_method}}
#
# output:
#   'this comes from an allowed method and this from another allowed method'
#
# You can also chain associations, by adding the liquid_method call in the
# association models.
#
# You may also pass a block that can be used to transform the method's returned value.
#
#   class SomeClass
#     liquid_methods :an_allowed_method do |object, method, value|
#       if value.is_a?(String)
#         value += ' that has been transformed'
#       else
#         value
#       end
#     end
#
#     def an_allowed_method
#       'this comes from an allowed method'
#     end
#
#   end
#
# usage:
#   @something = SomeClass.new
#
# template:
#   {{something.an_allowed_method}}
#
# output:
#   'this comes from an allowed method that has been transformed'
class Module
  def liquid_methods(*allowed_methods, &block)
    drop_class = eval "class #{self.to_s}::LiquidDropClass < Liquid::Drop; self; end"

    define_method :to_liquid do
      drop_class.new(self)
    end

    drop_class.class_eval do
      def initialize(object)
        @object = object
      end

      allowed_methods.each do |sym|
        define_method sym do
          _value = @object.send(sym)
          if block
            block.call(@object, sym, _value)
          else
            _value
          end
        end
      end
    end
  end
end
