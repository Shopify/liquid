/*
  Parser for context#[] method. Generated through ragel from parser.rl 
  Only modify parser.rl. Run rake ragel afterwards to generate this file. 
*/

#include <ruby.h>

%%{
  machine fsm;

  action mark {
    mark = p;
  }

  action lookup {
    EMIT("lookup", Qnil)
  }

  action call {
    EMIT("call", Qnil)
  }
  action range {
    EMIT("range", Qnil)
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

    integer       >mark %{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Integer"), 1, rb_str_new(mark, p - mark))); 
    } |

    float         >mark %{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Float"), 1, rb_str_new(mark, p - mark))) 
    } |

    nil           %{ EMIT("id", Qnil) } | 
    "true"        %{ EMIT("id", Qtrue) } |
    "false"       %{ EMIT("id", Qfalse) } |
    
    string        >mark %{ EMIT("id", rb_str_new(mark + 1, p - mark - 2)) } 

  );

  entity = (
    ((alpha [A-Za-z0-9_\-]*) - (constants)) >mark %{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("lookup", Qnil) 
    }
  );

  # Because of recursion we cannot immediatly resolve the content of this in 
  # the current grammar. We simply re-invoke the parser here to descend into 
  # the substring
  recur = (
    (any+ - ']') >mark %{
      VALUE body = rb_str_new(mark, p - mark);
      liquid_context_parse_impl(body, tokens);
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
      EMIT("buildin", rb_str_new2("first"))
    } |

    ".last"  %{ 
      EMIT("buildin", rb_str_new2("last"))
    } |

    ".size"  %{ 
      EMIT("buildin", rb_str_new2("size"))      
    } |

    "." ((alpha [A-Za-z0-9_\-]*) - ("first"|"last"|"size"))  >mark  %{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("call", Qnil) 
    }
  );

  main := ( 
    
    expr <: (hash_accessors)*

  );
    
}%%

%% write data nofinal;

// def self.emit(sym, data, tokens) 
//   puts "emitting: #{sym} -> #{data.inspect}" if $VERBOSE
//   tokens.push [sym, data]
// end

#define EMIT(sym, data) rb_ary_push(tokens, rb_ary_new3(2, ID2SYM(rb_intern(sym)), data)); 


void liquid_context_parse_impl(VALUE text, VALUE tokens)
{
  char *p;
  char *pe;
  char *eof;
  char *mark;
  int cs, res = 0;

  if (RSTRING_LEN(text) <= 0) {
    return;
  }
  
  mark = p = RSTRING_PTR(text); 
  eof = pe = RSTRING_PTR(text) + RSTRING_LEN(text);    

  %% write init;
  %% write exec;
}

VALUE liquid_context_parse(VALUE self, VALUE text) {
  VALUE tokens;

  //printf("text: %s\n", RSTRING_PTR(text));
  
  //Check_Type(text, T_STRING);

  tokens = rb_ary_new();
  liquid_context_parse_impl(text, tokens);
  return tokens;
}

static VALUE rb_Liquid;
static VALUE rb_Parser;

void Init_liquid_ext()
{
  rb_Liquid = rb_define_module("Liquid");
  rb_Parser = rb_define_class_under(rb_Liquid, "Parser", rb_cObject);
  rb_define_singleton_method(rb_Parser, "parse", liquid_context_parse, 1);  
}
