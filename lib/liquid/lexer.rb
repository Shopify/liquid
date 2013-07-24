module Liquid
  class Lexer
    SPECIALS = {
      '|' => :pipe,
      '.' => :dot,
      ':' => :colon,
      ',' => :comma
    }

    def tokenize(input)
      @p = 0
      @output = []
      @input = input.chars.to_a

      loop do
        consume_whitespace
        c = @input[@p]
        return @output unless c

        if identifier?(c)
          @output << consume_identifier
        elsif s = SPECIALS[c]
          @output << s
          @p += 1
        end
      end
    end

    def benchmark
      require 'benchmark'
      s = "bob.hello | filter: lol, troll"
      Benchmark.bmbm do |x|
        x.report('c') { 100_000.times { tokenize(s) }}  
        x.report('r') { 100_000.times { s.split(/\b/).map {|y| y.strip} }}  
      end 
    end

    def identifier?(c)
      c =~ /^[\w\-]$/
    end

    def whitespace?(c)
      c =~ /^\s$/
    end

    def consume_whitespace
      while whitespace?(@input[@p])
        @p += 1
      end
    end

    def consume_identifier
      str = ""
      while identifier?(@input[@p])
        str << @input[@p]
        @p += 1
      end
      str
    end
  end
end
