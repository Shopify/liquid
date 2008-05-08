require File.dirname(__FILE__) + '/helper'
class HundredCentes
  def to_liquid
    100
  end
end

class CentsDrop < Liquid::Drop
  def amount
    HundredCentes.new
  end
  
  def non_zero?
    true
  end
end

class ContextSensitiveDrop < Liquid::Drop
  def test
    @context['test']
  end
end

class Category < Liquid::Drop
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def to_liquid
    CategoryDrop.new(self)
  end
end

class CategoryDrop
  attr_accessor :category, :context
  def initialize(category)
    @category = category
  end
end


class ContextTest < Test::Unit::TestCase
  include Liquid

  def setup
    @template = Liquid::Template.new
    @context = Liquid::Context.new(@template.assigns, @template.registers)
  end

  def test_variables
    @context['string'] = 'string'
    assert_equal 'string', @context['string']
    
    @context['num'] = 5
    assert_equal 5, @context['num']
    
    @context['time'] = Time.parse('2006-06-06 12:00:00')
    assert_equal Time.parse('2006-06-06 12:00:00'), @context['time']
    
    @context['date'] = Date.today
    assert_equal Date.today, @context['date']
    
    now = DateTime.now
    @context['datetime'] = now
    assert_equal now, @context['datetime']    
    
    @context['bool'] = true
    assert_equal true, @context['bool']    
    
    @context['bool'] = false
    assert_equal false, @context['bool']
    
    @context['nil'] = nil
    assert_equal nil, @context['nil']
    assert_equal nil, @context['nil']    
  end
  
  def test_variables_not_existing
    assert_equal nil, @context['does_not_exist']
  end
  
  def test_scoping
    assert_nothing_raised do
      @context.push
      @context.pop
    end
    
    assert_raise(Liquid::ContextError) do
      @context.pop
    end

    assert_raise(Liquid::ContextError) do
      @context.push
      @context.pop
      @context.pop
    end
  end
  
  def test_length_query
    
    @context['numbers'] = [1,2,3,4]
    
    assert_equal 4, @context['numbers.size']

    @context['numbers'] = {1 => 1,2 => 2,3 => 3,4 => 4}

    assert_equal 4, @context['numbers.size']
    
    @context['numbers'] = {1 => 1,2 => 2,3 => 3,4 => 4, 'size' => 1000}

    assert_equal 1000, @context['numbers.size']
    
  end           
  
  def test_hyphenated_variable

    @context['oh-my'] = 'godz'
    assert_equal 'godz', @context['oh-my']
    
  end
  
  def test_add_filter
    
    filter = Module.new do 
      def hi(output)
        output + ' hi!'
      end
    end
    
    context = Context.new(@template)
    context.add_filters(filter)
    assert_equal 'hi? hi!', context.invoke(:hi, 'hi?')
    
    context = Context.new(@template)
    assert_equal 'hi?', context.invoke(:hi, 'hi?')

    context.add_filters(filter)
    assert_equal 'hi? hi!', context.invoke(:hi, 'hi?')
        
  end
  
  def test_override_global_filter
    global = Module.new do 
      def notice(output)
        "Global #{output}"
      end
    end
    
    local = Module.new do 
      def notice(output)
        "Local #{output}"
      end
    end
        
    Template.register_filter(global)    
    assert_equal 'Global test', Template.parse("{{'test' | notice }}").render
    assert_equal 'Local test', Template.parse("{{'test' | notice }}").render({}, :filters => [local])
  end
    
  def test_only_intended_filters_make_it_there

    filter = Module.new do 
      def hi(output)
        output + ' hi!'
      end
    end

    context = Context.new(@template)
    methods = context.strainer.methods
    context.add_filters(filter)
    assert_equal (methods + ['hi']).sort, context.strainer.methods.sort
  end
  
  def test_add_item_in_outer_scope
    @context['test'] = 'test'
    @context.push
    assert_equal 'test', @context['test']
    @context.pop    
    assert_equal 'test', @context['test']    
  end

  def test_add_item_in_inner_scope
    @context.push
    @context['test'] = 'test'
    assert_equal 'test', @context['test']
    @context.pop    
    assert_equal nil, @context['test']    
  end
  
  def test_hierachical_data
    @context['hash'] = {"name" => 'tobi'}
    assert_equal 'tobi', @context['hash.name']
  end
  
  def test_keywords
    assert_equal true, @context['true']
    assert_equal false, @context['false']
  end

  def test_digits
    assert_equal 100, @context['100']
    assert_equal 100.00, @context['100.00']
  end
  
  def test_strings
    assert_equal "hello!", @context['"hello!"']
    assert_equal "hello!", @context["'hello!'"]
  end  
  
  def test_merge
    @context.merge({ "test" => "test" })
    assert_equal 'test', @context['test']
    @context.merge({ "test" => "newvalue", "foo" => "bar" })
    assert_equal 'newvalue', @context['test']
    assert_equal 'bar', @context['foo']    
  end
  
  def test_array_notation
    @context['test'] = [1,2,3,4,5]

    assert_equal 1, @context['test[0]']
    assert_equal 2, @context['test[1]']
    assert_equal 3, @context['test[2]']
    assert_equal 4, @context['test[3]']
    assert_equal 5, @context['test[4]']    
  end
  
  def test_recoursive_array_notation
    @context['test'] = {'test' => [1,2,3,4,5]}

    assert_equal 1, @context['test.test[0]']
   
    @context['test'] = [{'test' => 'worked'}]

    assert_equal 'worked', @context['test[0].test']    
  end
  
  def test_hash_to_array_transition
    @context['colors'] = {
     'Blue'    => ['003366','336699', '6699CC', '99CCFF'],
     'Green'   => ['003300','336633', '669966', '99CC99'],
     'Yellow'  => ['CC9900','FFCC00', 'FFFF99', 'FFFFCC'],
     'Red'     => ['660000','993333', 'CC6666', 'FF9999']
    } 

    assert_equal '003366', @context['colors.Blue[0]']
    assert_equal 'FF9999', @context['colors.Red[3]']
  end
  
  def test_try_first
    @context['test'] = [1,2,3,4,5]

    assert_equal 1, @context['test.first']
    assert_equal 5, @context['test.last']
    
    @context['test'] = {'test' => [1,2,3,4,5]}
        
    assert_equal 1, @context['test.test.first']
    assert_equal 5, @context['test.test.last']    
    
    @context['test'] = [1]
    assert_equal 1, @context['test.first']
    assert_equal 1, @context['test.last']        
  end

  def test_access_hashes_with_hash_notation
    
    @context['products'] = {'count' => 5, 'tags' => ['deepsnow', 'freestyle'] }
    @context['product'] = {'variants' => [ {'title' => 'draft151cm'}, {'title' => 'element151cm'}  ]}


    assert_equal 5, @context['products["count"]']
    assert_equal 'deepsnow', @context['products["tags"][0]']
    assert_equal 'deepsnow', @context['products["tags"].first']
    assert_equal 'draft151cm', @context['product["variants"][0]["title"]']
    assert_equal 'element151cm', @context['product["variants"][1]["title"]']
    assert_equal 'draft151cm', @context['product["variants"][0]["title"]']
    assert_equal 'element151cm', @context['product["variants"].last["title"]']
  end
  
  def test_access_variable_with_hash_notation
    @context['foo'] = 'baz'
    @context['bar'] = 'foo'
    
    assert_equal 'baz', @context['["foo"]']
    assert_equal 'baz', @context['[bar]']
  end
  
  def test_access_hashes_with_hash_access_variables
    
    @context['var'] = 'tags'
    @context['nested'] = {'var' => 'tags'}
    @context['products'] = {'count' => 5, 'tags' => ['deepsnow', 'freestyle'] }

    assert_equal 'deepsnow', @context['products[var].first']
    assert_equal 'freestyle', @context['products[nested.var].last']
  end
  

  def test_first_can_appear_in_middle_of_callchain

    @context['product'] = {'variants' => [ {'title' => 'draft151cm'}, {'title' => 'element151cm'}  ]}

    assert_equal 'draft151cm', @context['product.variants[0].title']
    assert_equal 'element151cm', @context['product.variants[1].title']
    assert_equal 'draft151cm', @context['product.variants.first.title']
    assert_equal 'element151cm', @context['product.variants.last.title']
    
  end
  
  def test_cents
    @context.merge( "cents" => HundredCentes.new )
    assert_equal 100, @context['cents']
  end

  def test_nested_cents
    @context.merge( "cents" => { 'amount' => HundredCentes.new} )
    assert_equal 100, @context['cents.amount']    

    @context.merge( "cents" => { 'cents' => { 'amount' => HundredCentes.new} } )
    assert_equal 100, @context['cents.cents.amount']    
  end
  
  def test_cents_through_drop
    @context.merge( "cents" => CentsDrop.new )
    assert_equal 100, @context['cents.amount']     
  end
  
  def test_nested_cents_through_drop
    @context.merge( "vars" => {"cents" => CentsDrop.new} )
    assert_equal 100, @context['vars.cents.amount']     
  end
  
  def test_drop_methods_with_question_marks
    @context.merge( "cents" => CentsDrop.new )
    assert @context['cents.non_zero?']     
  end

  def test_context_from_within_drop
    @context.merge( "test" => '123', "vars" => ContextSensitiveDrop.new )
    assert_equal '123', @context['vars.test']     
  end

  def test_nested_context_from_within_drop
    @context.merge( "test" => '123', "vars" => {"local" => ContextSensitiveDrop.new }  )
    assert_equal '123', @context['vars.local.test']     
  end
  
  def test_ranges
    @context.merge( "test" => '5' )
    assert_equal (1..5), @context['(1..5)']
    assert_equal (1..5), @context['(1..test)']
    assert_equal (5..5), @context['(test..test)']
  end

  def test_cents_through_drop_nestedly
    @context.merge( "cents" => {"cents" => CentsDrop.new} )
    assert_equal 100, @context['cents.cents.amount']     

    @context.merge( "cents" => { "cents" => {"cents" => CentsDrop.new}} )
    assert_equal 100, @context['cents.cents.cents.amount']     
  end
  
  def test_proc_as_variable
    @context['dynamic'] = Proc.new { 'Hello' }
    
    assert_equal 'Hello', @context['dynamic']
  end

  def test_lambda_as_variable
    @context['dynamic'] = lambda { 'Hello' }
    
    assert_equal 'Hello', @context['dynamic']
  end

  def test_nested_lambda_as_variable
    @context['dynamic'] = { "lambda" => lambda { 'Hello' } }
    
    assert_equal 'Hello', @context['dynamic.lambda']
  end
  
  def test_lambda_is_called_once
    @context['callcount'] = lambda { @global ||= 0; @global += 1; @global.to_s }
    
    assert_equal '1', @context['callcount']
    assert_equal '1', @context['callcount']
    assert_equal '1', @context['callcount']    
    
    @global = nil
  end

  def test_nested_lambda_is_called_once
    @context['callcount'] = { "lambda" => lambda { @global ||= 0; @global += 1; @global.to_s } }
    
    assert_equal '1', @context['callcount.lambda']
    assert_equal '1', @context['callcount.lambda']
    assert_equal '1', @context['callcount.lambda']    

    @global = nil
  end
  
  def test_access_to_context_from_proc
    @context.registers[:magic] = 345392
    
    @context['magic'] = lambda { @context.registers[:magic] }
    
    assert_equal 345392, @context['magic']    
  end
  
  def test_to_liquid_and_context_at_first_level
    @context['category'] = Category.new("foobar")
    assert_kind_of CategoryDrop, @context['category']
    assert_equal @context, @context['category'].context
  end

end