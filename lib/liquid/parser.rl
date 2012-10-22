=begin
      LITERALS = {
        nil => nil, 'nil' => nil, 'null' => nil, '' => nil,
        'true'  => true,
        'false' => false,
        'blank' => :blank?,
        'empty' => :empty?
      }

      def resolve(key)
        if LITERALS.key?(key)
          LITERALS[key]
        else
          case key
          when /^'(.*)'$/ # Single quoted strings
            $1
          when /^"(.*)"$/ # Double quoted strings
            $1
          when /^(-?\d+)$/ # Integer and floats
            $1.to_i
          when /^\((\S+)\.\.(\S+)\)$/ # Ranges
            (resolve($1).to_i..resolve($2).to_i)
          when /^(-?\d[\d\.]+)$/ # Floats
            $1.to_f
          else
            variable(key)
          end
        end
      end
=end
%%{
  machine fsm;

  action mark {
    mark = p
  }

  action lookup {
    emit(:lookup, :instruction, nil, tokens)
  }

  action range {
    emit(:range, :instruction, nil, tokens)
  }

  var = [a-zA-Z][0-9A-Za-z_]+;

  # strings 
  string = "\"" any* "\"" | "'" any* "'";

  # nothingness
  nil = "nil" | "null" ;

  integer = ('+'|'-')? digit+;
  float = ('+'|'-')? digit+ '.' digit+;

  primitive = (

    integer >mark %{ emit(:id, :integer, Integer(data[mark..p-1]), tokens) } |

    float >mark %{ emit(:id, :float, Float(data[mark..p-1]), tokens) } |

    nil %{ emit(:id, :nil, nil, tokens) } | 
    "true" %{ emit(:id, :bool, true, tokens) } |
    "false" %{ emit(:id, :bool, false, tokens)} |
    
    string >mark %{ emit(:id, :string, data[mark+1..p-2], tokens) } 

  );

  constants = ( "true" | "false" | "nil" | "null" );

  entity = (
    ((alpha [A-Za-z0-9_]*) - (constants)) >mark %{ 
      emit(:id, :label, data[mark..p-1], tokens) 
      emit(:lookup, :variable, nil, tokens) 
    }
  );


  main := ( 
    entity |
    primitive |
     

    "(" (primitive | entity) ".." (primitive | entity) <: ")"  %range |
    "[" (primitive | entity) "]" %lookup    
    
  );
    
}%%
# % fix syntax highlighting


module Liquid
  module Parser
    %% write data;

    def self.emit(sym, type, data, tokens) 
      puts "emitting: #{type} #{sym} -> #{data.inspect}"
      tokens.push [sym, data]
    end

    def self.parse(data)      
      eof = data.length  
      tokens = []

      %% write init;
      %% write exec;   
      return tokens 
    end
  end
end