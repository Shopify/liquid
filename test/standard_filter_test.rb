#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/helper'


class Filters
  include Liquid::StandardFilters
end


class StandardFiltersTest < Test::Unit::TestCase
  include Liquid
  
  def setup
    @filters = Filters.new
  end
  
  def test_size
    assert_equal 3, @filters.size([1,2,3])
    assert_equal 0, @filters.size([])
    assert_equal 0, @filters.size(nil)
  end
  
  def test_downcase
    assert_equal 'testing', @filters.downcase("Testing")
    assert_equal '', @filters.downcase(nil)
  end
  
  def test_upcase
    assert_equal 'TESTING', @filters.upcase("Testing")
    assert_equal '', @filters.upcase(nil)
  end
  
  def test_upcase
    assert_equal 'TESTING', @filters.upcase("Testing")
    assert_equal '', @filters.upcase(nil)
  end
  
  def test_truncate
    assert_equal '1234...', @filters.truncate('1234567890', 7)
    assert_equal '1234567890', @filters.truncate('1234567890', 20)
    assert_equal '...', @filters.truncate('1234567890', 0)
    assert_equal '1234567890', @filters.truncate('1234567890')
  end
  
  def test_escape
    assert_equal '&lt;strong&gt;', @filters.escape('<strong>')
    assert_equal '&lt;strong&gt;', @filters.h('<strong>')    
  end
  
  def test_truncatewords
    assert_equal 'one two three', @filters.truncatewords('one two three', 4)
    assert_equal 'one two...', @filters.truncatewords('one two three', 2)
    assert_equal 'one two three', @filters.truncatewords('one two three')
    assert_equal 'Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221;...', @filters.truncatewords('Two small (13&#8221; x 5.5&#8221; x 10&#8221; high) baskets fit inside one large basket (13&#8221; x 16&#8221; x 10.5&#8221; high) with cover.', 15)    
  end
  
  def test_strip_html
    assert_equal 'test', @filters.strip_html("<div>test</div>")    
    assert_equal 'test', @filters.strip_html("<div id='test'>test</div>")    
    assert_equal '', @filters.strip_html(nil)    
  end
  
  def test_join
    assert_equal '1 2 3 4', @filters.join([1,2,3,4])    
    assert_equal '1 - 2 - 3 - 4', @filters.join([1,2,3,4], ' - ')    
  end
  
  def test_sort
    assert_equal [1,2,3,4], @filters.sort([4,3,2,1])    
  end
  
  def test_date
    assert_equal 'May', @filters.date(Time.parse("2006-05-05 10:00:00"), "%B")    
    assert_equal 'June', @filters.date(Time.parse("2006-06-05 10:00:00"), "%B")    
    assert_equal 'July', @filters.date(Time.parse("2006-07-05 10:00:00"), "%B")    

    assert_equal 'May', @filters.date("2006-05-05 10:00:00", "%B")    
    assert_equal 'June', @filters.date("2006-06-05 10:00:00", "%B")    
    assert_equal 'July', @filters.date("2006-07-05 10:00:00", "%B")    

    assert_equal '2006-07-05 10:00:00', @filters.date("2006-07-05 10:00:00", "")    
    assert_equal '2006-07-05 10:00:00', @filters.date("2006-07-05 10:00:00", "")    
    assert_equal '2006-07-05 10:00:00', @filters.date("2006-07-05 10:00:00", "")    
    assert_equal '2006-07-05 10:00:00', @filters.date("2006-07-05 10:00:00", nil)    

    assert_equal '07/05/2006', @filters.date("2006-07-05 10:00:00", "%m/%d/%Y")    
    
    assert_equal "07/16/2004", @filters.date("Fri Jul 16 01:00:00 EDT 2004", "%m/%d/%Y")
    
    assert_equal nil, @filters.date(nil, "%B")    
  end
  
  
  def test_first_last
    assert_equal 1, @filters.first([1,2,3])    
    assert_equal 3, @filters.last([1,2,3])    
    assert_equal nil, @filters.first([])    
    assert_equal nil, @filters.last([])    
  end
  
  def test_replace
    assert_equal 'b b b b', @filters.replace("a a a a", 'a', 'b')    
    assert_equal 'b a a a', @filters.replace_first("a a a a", 'a', 'b')
    assert_template_result 'b a a a', "{{ 'a a a a' | replace_first: 'a', 'b' }}"        
  end
  
  def test_remove
    assert_equal '   ', @filters.remove("a a a a", 'a')    
    assert_equal 'a a a', @filters.remove_first("a a a a", 'a ')        
    assert_template_result 'a a a', "{{ 'a a a a' | remove_first: 'a ' }}"
  end
                                                                                     
  def test_strip_newlines
    assert_template_result 'abc', "{{ source | strip_newlines }}", 'source' => "a\nb\nc"
  end
  
  def test_newlines_to_br
    assert_template_result "a<br />\nb<br />\nc", "{{ source | newline_to_br }}", 'source' => "a\nb\nc"
  end
  
  
  
  
  
end

