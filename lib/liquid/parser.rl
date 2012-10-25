# Parser for context#[] method. Generated through ragel from parser.rl 
# Only modify parser.rl. Run rake ragel afterwards to generate this file. 
#
#VERBOSE=true

%%{
  machine fsm;

  action mark {
    mark = p
  }

  action lookup {
    emit(:lookup, :instruction, nil, tokens)
  }

  action call {
    emit(:call, :instruction, nil, tokens)
  }
  action range {
    emit(:range, :instruction, nil, tokens)
  }

  constants = ( "true" | "false" | "nil" | "null" );

  # strings 
  string = "\"" any* "\"" | "'" any* "'";

  # nothingness
  nil = "nil" | "null" ;

  # numbers
  integer = ('+'|'-')? digit+;
  float = ('+'|'-')? digit+ '.' digit+;

  # simple values
  primitive = (

    integer       >mark %{ emit(:id, :integer, Integer(data[mark..p-1]), tokens) } |

    float         >mark %{ emit(:id, :float, Float(data[mark..p-1]), tokens) } |

    nil           %{ emit(:id, :nil, nil, tokens) } | 
    "true"        %{ emit(:id, :bool, true, tokens) } |
    "false"       %{ emit(:id, :bool, false, tokens)} |
    
    string        >mark %{ emit(:id, :string, data[mark+1..p-2], tokens) } 

  );

  entity = (
    ((alpha [A-Za-z0-9_\-]*) - (constants)) >mark %{ 
      emit(:id, :label, data[mark..p-1], tokens) 
      emit(:lookup, :variable, nil, tokens) 
    }
  );

  # Because of recursion we cannot immediatly resolve the content of this in 
  # the current grammar. We simply re-invoke the parser here to descend into 
  # the substring
  recur = (
    (any+ - ']') >mark %{       
      self.parse(data[mark..p-1], tokens)
    }
  );

  expr = (
    entity |
    primitive |    
    "(" (primitive | entity) ".." (primitive | entity) <: ")"  %range |
    "[" recur "]" %lookup    
  );

  hash_accessors  = (
    "[" recur "]" %call |

    ".first"  %{ 
      emit(:buildin, :symbol, "first", tokens)       
    } |

    ".last"  %{ 
      emit(:buildin, :symbol, "last", tokens)       
    } |

    ".size"  %{ 
      emit(:buildin, :symbol, "size", tokens)       
    } |

    "." ((alpha [A-Za-z0-9_\-]*) - ("first"|"last"|"size"))  >mark  %{ 
      emit(:id, :label, data[mark..p-1], tokens) 
      emit(:call, :variable, nil, tokens) 
    }
  );

  main := ( 
    
    expr <: (hash_accessors)*

  );
    
}%%
# % fix syntax highlighting


module Liquid
  module Parser
    %% write data;

    def self.emit(sym, type, data, tokens) 
      puts "emitting: #{type} #{sym} -> #{data.inspect}" if $VERBOSE
      tokens.push [sym, data]
    end

    def self.parse(data, tokens = [])      
      puts "--> self.parse with #{data.inspect}, #{tokens.inspect}" if $VERBOSE

      eof = data.length  

      %% write init;
      %% write exec;   

      puts "<-- #{tokens.inspect}" if $VERBOSE
      return tokens 
    end
  end
end