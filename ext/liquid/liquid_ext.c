
#line 1 "./ext/liquid/liquid_ext.rl"
/*
  Parser for context#[] method. Generated through ragel from parser.rl 
  Only modify parser.rl. Run rake ragel afterwards to generate this file. 
*/

#include <ruby.h>


#line 108 "./ext/liquid/liquid_ext.rl"



#line 16 "./ext/liquid/liquid_ext.c"
static const int fsm_start = 1;
static const int fsm_error = 0;

static const int fsm_en_main = 1;


#line 111 "./ext/liquid/liquid_ext.rl"

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

  
#line 49 "./ext/liquid/liquid_ext.c"
	{
	cs = fsm_start;
	}

#line 136 "./ext/liquid/liquid_ext.rl"
  
#line 56 "./ext/liquid/liquid_ext.c"
	{
	if ( p == pe )
		goto _test_eof;
	switch ( cs )
	{
case 1:
	switch( (*p) ) {
		case 34: goto tr0;
		case 39: goto tr2;
		case 40: goto st4;
		case 43: goto tr4;
		case 45: goto tr4;
		case 91: goto st60;
		case 102: goto tr8;
		case 110: goto tr9;
		case 116: goto tr10;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr5;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr6;
	} else
		goto tr6;
	goto st0;
st0:
cs = 0;
	goto _out;
tr0:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st2;
st2:
	if ( ++p == pe )
		goto _test_eof2;
case 2:
#line 96 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 34 )
		goto st63;
	goto st2;
st63:
	if ( ++p == pe )
		goto _test_eof63;
case 63:
	if ( (*p) == 34 )
		goto st63;
	goto st2;
tr2:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st3;
st3:
	if ( ++p == pe )
		goto _test_eof3;
case 3:
#line 117 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 39 )
		goto st64;
	goto st3;
st64:
	if ( ++p == pe )
		goto _test_eof64;
case 64:
	if ( (*p) == 39 )
		goto st64;
	goto st3;
st4:
	if ( ++p == pe )
		goto _test_eof4;
case 4:
	switch( (*p) ) {
		case 34: goto tr15;
		case 39: goto tr16;
		case 43: goto tr17;
		case 45: goto tr17;
		case 102: goto tr20;
		case 110: goto tr21;
		case 116: goto tr22;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr18;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr19;
	} else
		goto tr19;
	goto st0;
tr15:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st5;
st5:
	if ( ++p == pe )
		goto _test_eof5;
case 5:
#line 160 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 34 )
		goto st6;
	goto st5;
tr27:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st6;
st6:
	if ( ++p == pe )
		goto _test_eof6;
case 6:
#line 174 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 34: goto st6;
		case 46: goto tr25;
	}
	goto st5;
tr25:
#line 53 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", rb_str_new(mark + 1, p - mark - 2)) }
	goto st7;
st7:
	if ( ++p == pe )
		goto _test_eof7;
case 7:
#line 188 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 34: goto st6;
		case 46: goto st8;
	}
	goto st5;
st8:
	if ( ++p == pe )
		goto _test_eof8;
case 8:
	switch( (*p) ) {
		case 34: goto tr27;
		case 39: goto tr15;
		case 43: goto tr15;
		case 45: goto tr15;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr15;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr15;
	} else
		goto tr15;
	goto st5;
tr16:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st9;
st9:
	if ( ++p == pe )
		goto _test_eof9;
case 9:
#line 223 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 39 )
		goto st10;
	goto st9;
tr32:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st10;
st10:
	if ( ++p == pe )
		goto _test_eof10;
case 10:
#line 237 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 39: goto st10;
		case 46: goto tr30;
	}
	goto st9;
tr30:
#line 53 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", rb_str_new(mark + 1, p - mark - 2)) }
	goto st11;
st11:
	if ( ++p == pe )
		goto _test_eof11;
case 11:
#line 251 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 39: goto st10;
		case 46: goto st12;
	}
	goto st9;
st12:
	if ( ++p == pe )
		goto _test_eof12;
case 12:
	switch( (*p) ) {
		case 34: goto tr16;
		case 39: goto tr32;
		case 43: goto tr16;
		case 45: goto tr16;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr16;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr16;
	} else
		goto tr16;
	goto st9;
tr17:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st13;
st13:
	if ( ++p == pe )
		goto _test_eof13;
case 13:
#line 286 "./ext/liquid/liquid_ext.c"
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st14;
	goto st0;
tr18:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st14;
st14:
	if ( ++p == pe )
		goto _test_eof14;
case 14:
#line 300 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 46 )
		goto tr34;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st14;
	goto st0;
tr34:
#line 41 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Integer"), 1, rb_str_new(mark, p - mark))); 
    }
	goto st15;
st15:
	if ( ++p == pe )
		goto _test_eof15;
case 15:
#line 316 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 46 )
		goto st16;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st42;
	goto st0;
st16:
	if ( ++p == pe )
		goto _test_eof16;
case 16:
	switch( (*p) ) {
		case 34: goto tr37;
		case 39: goto tr37;
		case 43: goto tr38;
		case 45: goto tr38;
		case 102: goto tr41;
		case 110: goto tr42;
		case 116: goto tr43;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr39;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr40;
	} else
		goto tr40;
	goto st0;
tr37:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st17;
st17:
	if ( ++p == pe )
		goto _test_eof17;
case 17:
#line 354 "./ext/liquid/liquid_ext.c"
	goto st17;
tr38:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st18;
st18:
	if ( ++p == pe )
		goto _test_eof18;
case 18:
#line 366 "./ext/liquid/liquid_ext.c"
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st19;
	goto st0;
tr39:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st19;
st19:
	if ( ++p == pe )
		goto _test_eof19;
case 19:
#line 380 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 41: goto tr46;
		case 46: goto st26;
	}
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st19;
	goto st0;
tr46:
#line 41 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Integer"), 1, rb_str_new(mark, p - mark))); 
    }
	goto st65;
tr62:
#line 45 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Float"), 1, rb_str_new(mark, p - mark))) 
    }
	goto st65;
tr63:
#line 58 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("lookup", Qnil) 
    }
	goto st65;
tr69:
#line 51 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qfalse) }
	goto st65;
tr73:
#line 49 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qnil) }
	goto st65;
tr77:
#line 50 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qtrue) }
	goto st65;
st65:
	if ( ++p == pe )
		goto _test_eof65;
case 65:
#line 423 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 46: goto tr100;
		case 91: goto tr101;
	}
	goto st0;
tr144:
#line 45 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Float"), 1, rb_str_new(mark, p - mark))) 
    }
	goto st20;
tr147:
#line 58 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("lookup", Qnil) 
    }
	goto st20;
tr153:
#line 51 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qfalse) }
	goto st20;
tr158:
#line 49 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qnil) }
	goto st20;
tr163:
#line 50 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qtrue) }
	goto st20;
tr100:
#line 22 "./ext/liquid/liquid_ext.rl"
	{
    EMIT("range", Qnil)
  }
	goto st20;
tr103:
#line 96 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("call", Qnil) 
    }
	goto st20;
tr130:
#line 84 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("first"))
    }
	goto st20;
tr135:
#line 88 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("last"))
    }
	goto st20;
tr140:
#line 92 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("size"))      
    }
	goto st20;
st20:
	if ( ++p == pe )
		goto _test_eof20;
case 20:
#line 489 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 102: goto tr49;
		case 108: goto tr50;
		case 115: goto tr51;
	}
	if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr48;
	} else if ( (*p) >= 65 )
		goto tr48;
	goto st0;
tr48:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st66;
st66:
	if ( ++p == pe )
		goto _test_eof66;
case 66:
#line 511 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
tr143:
#line 41 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Integer"), 1, rb_str_new(mark, p - mark))); 
    }
	goto st21;
tr145:
#line 45 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Float"), 1, rb_str_new(mark, p - mark))) 
    }
	goto st21;
tr148:
#line 58 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("lookup", Qnil) 
    }
	goto st21;
tr154:
#line 51 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qfalse) }
	goto st21;
tr159:
#line 49 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qnil) }
	goto st21;
tr164:
#line 50 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qtrue) }
	goto st21;
tr101:
#line 22 "./ext/liquid/liquid_ext.rl"
	{
    EMIT("range", Qnil)
  }
	goto st21;
tr104:
#line 96 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("call", Qnil) 
    }
	goto st21;
tr131:
#line 84 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("first"))
    }
	goto st21;
tr136:
#line 88 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("last"))
    }
	goto st21;
tr141:
#line 92 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("size"))      
    }
	goto st21;
st21:
	if ( ++p == pe )
		goto _test_eof21;
case 21:
#line 593 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 93 )
		goto tr53;
	goto tr52;
tr52:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st22;
st22:
	if ( ++p == pe )
		goto _test_eof22;
case 22:
#line 607 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 93 )
		goto tr55;
	goto st22;
tr55:
#line 68 "./ext/liquid/liquid_ext.rl"
	{
      VALUE body = rb_str_new(mark, p - mark);
      liquid_context_parse_impl(body, tokens);
    }
	goto st67;
tr60:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
#line 68 "./ext/liquid/liquid_ext.rl"
	{
      VALUE body = rb_str_new(mark, p - mark);
      liquid_context_parse_impl(body, tokens);
    }
	goto st67;
st67:
	if ( ++p == pe )
		goto _test_eof67;
case 67:
#line 633 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 46: goto tr105;
		case 91: goto tr106;
		case 93: goto tr55;
	}
	goto st22;
tr108:
#line 96 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("call", Qnil) 
    }
	goto st23;
tr105:
#line 19 "./ext/liquid/liquid_ext.rl"
	{
    EMIT("call", Qnil)
  }
	goto st23;
tr114:
#line 84 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("first"))
    }
	goto st23;
tr119:
#line 88 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("last"))
    }
	goto st23;
tr124:
#line 92 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("size"))      
    }
	goto st23;
st23:
	if ( ++p == pe )
		goto _test_eof23;
case 23:
#line 675 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 93: goto tr55;
		case 102: goto tr57;
		case 108: goto tr58;
		case 115: goto tr59;
	}
	if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr56;
	} else if ( (*p) >= 65 )
		goto tr56;
	goto st22;
tr56:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st68;
st68:
	if ( ++p == pe )
		goto _test_eof68;
case 68:
#line 698 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
tr109:
#line 96 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("call", Qnil) 
    }
	goto st24;
tr106:
#line 19 "./ext/liquid/liquid_ext.rl"
	{
    EMIT("call", Qnil)
  }
	goto st24;
tr115:
#line 84 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("first"))
    }
	goto st24;
tr120:
#line 88 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("last"))
    }
	goto st24;
tr125:
#line 92 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("size"))      
    }
	goto st24;
st24:
	if ( ++p == pe )
		goto _test_eof24;
case 24:
#line 750 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 93 )
		goto tr60;
	goto tr52;
tr57:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st69;
st69:
	if ( ++p == pe )
		goto _test_eof69;
case 69:
#line 764 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 105: goto st70;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st70:
	if ( ++p == pe )
		goto _test_eof70;
case 70:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 114: goto st71;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st71:
	if ( ++p == pe )
		goto _test_eof71;
case 71:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 115: goto st72;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st72:
	if ( ++p == pe )
		goto _test_eof72;
case 72:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 116: goto st73;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st73:
	if ( ++p == pe )
		goto _test_eof73;
case 73:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr114;
		case 91: goto tr115;
		case 93: goto tr55;
		case 95: goto st68;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
tr58:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st74;
st74:
	if ( ++p == pe )
		goto _test_eof74;
case 74:
#line 875 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 97: goto st75;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 98 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st75:
	if ( ++p == pe )
		goto _test_eof75;
case 75:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 115: goto st76;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st76:
	if ( ++p == pe )
		goto _test_eof76;
case 76:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 116: goto st77;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st77:
	if ( ++p == pe )
		goto _test_eof77;
case 77:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr119;
		case 91: goto tr120;
		case 93: goto tr55;
		case 95: goto st68;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
tr59:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st78;
st78:
	if ( ++p == pe )
		goto _test_eof78;
case 78:
#line 965 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 105: goto st79;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st79:
	if ( ++p == pe )
		goto _test_eof79;
case 79:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 122: goto st80;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 121 )
			goto st68;
	} else
		goto st68;
	goto st22;
st80:
	if ( ++p == pe )
		goto _test_eof80;
case 80:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr108;
		case 91: goto tr109;
		case 93: goto tr55;
		case 95: goto st68;
		case 101: goto st81;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
st81:
	if ( ++p == pe )
		goto _test_eof81;
case 81:
	switch( (*p) ) {
		case 45: goto st68;
		case 46: goto tr124;
		case 91: goto tr125;
		case 93: goto tr55;
		case 95: goto st68;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st68;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st68;
	} else
		goto st68;
	goto st22;
tr53:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st25;
st25:
	if ( ++p == pe )
		goto _test_eof25;
case 25:
#line 1055 "./ext/liquid/liquid_ext.c"
	goto st22;
tr49:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st82;
st82:
	if ( ++p == pe )
		goto _test_eof82;
case 82:
#line 1067 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 105: goto st83;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st83:
	if ( ++p == pe )
		goto _test_eof83;
case 83:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 114: goto st84;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st84:
	if ( ++p == pe )
		goto _test_eof84;
case 84:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 115: goto st85;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st85:
	if ( ++p == pe )
		goto _test_eof85;
case 85:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 116: goto st86;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st86:
	if ( ++p == pe )
		goto _test_eof86;
case 86:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr130;
		case 91: goto tr131;
		case 95: goto st66;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
tr50:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st87;
st87:
	if ( ++p == pe )
		goto _test_eof87;
case 87:
#line 1173 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 97: goto st88;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 98 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st88:
	if ( ++p == pe )
		goto _test_eof88;
case 88:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 115: goto st89;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st89:
	if ( ++p == pe )
		goto _test_eof89;
case 89:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 116: goto st90;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st90:
	if ( ++p == pe )
		goto _test_eof90;
case 90:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr135;
		case 91: goto tr136;
		case 95: goto st66;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
tr51:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st91;
st91:
	if ( ++p == pe )
		goto _test_eof91;
case 91:
#line 1259 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 105: goto st92;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st92:
	if ( ++p == pe )
		goto _test_eof92;
case 92:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 122: goto st93;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 121 )
			goto st66;
	} else
		goto st66;
	goto st0;
st93:
	if ( ++p == pe )
		goto _test_eof93;
case 93:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr103;
		case 91: goto tr104;
		case 95: goto st66;
		case 101: goto st94;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st94:
	if ( ++p == pe )
		goto _test_eof94;
case 94:
	switch( (*p) ) {
		case 45: goto st66;
		case 46: goto tr140;
		case 91: goto tr141;
		case 95: goto st66;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st66;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st66;
	} else
		goto st66;
	goto st0;
st26:
	if ( ++p == pe )
		goto _test_eof26;
case 26:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st27;
	goto st0;
st27:
	if ( ++p == pe )
		goto _test_eof27;
case 27:
	if ( (*p) == 41 )
		goto tr62;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st27;
	goto st0;
tr40:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st28;
st28:
	if ( ++p == pe )
		goto _test_eof28;
case 28:
#line 1361 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
tr41:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st29;
st29:
	if ( ++p == pe )
		goto _test_eof29;
case 29:
#line 1386 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 97: goto st30;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 98 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st30:
	if ( ++p == pe )
		goto _test_eof30;
case 30:
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 108: goto st31;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st31:
	if ( ++p == pe )
		goto _test_eof31;
case 31:
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 115: goto st32;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st32:
	if ( ++p == pe )
		goto _test_eof32;
case 32:
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 101: goto st33;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st33:
	if ( ++p == pe )
		goto _test_eof33;
case 33:
	switch( (*p) ) {
		case 41: goto tr69;
		case 45: goto st28;
		case 95: goto st28;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
tr42:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st34;
st34:
	if ( ++p == pe )
		goto _test_eof34;
case 34:
#line 1487 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 105: goto st35;
		case 117: goto st37;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st35:
	if ( ++p == pe )
		goto _test_eof35;
case 35:
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 108: goto st36;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st36:
	if ( ++p == pe )
		goto _test_eof36;
case 36:
	switch( (*p) ) {
		case 41: goto tr73;
		case 45: goto st28;
		case 95: goto st28;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st37:
	if ( ++p == pe )
		goto _test_eof37;
case 37:
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 108: goto st35;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
tr43:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st38;
st38:
	if ( ++p == pe )
		goto _test_eof38;
case 38:
#line 1570 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 114: goto st39;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st39:
	if ( ++p == pe )
		goto _test_eof39;
case 39:
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 117: goto st40;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st40:
	if ( ++p == pe )
		goto _test_eof40;
case 40:
	switch( (*p) ) {
		case 41: goto tr63;
		case 45: goto st28;
		case 95: goto st28;
		case 101: goto st41;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st41:
	if ( ++p == pe )
		goto _test_eof41;
case 41:
	switch( (*p) ) {
		case 41: goto tr77;
		case 45: goto st28;
		case 95: goto st28;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st28;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st28;
	} else
		goto st28;
	goto st0;
st42:
	if ( ++p == pe )
		goto _test_eof42;
case 42:
	if ( (*p) == 46 )
		goto tr78;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st42;
	goto st0;
tr78:
#line 45 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Float"), 1, rb_str_new(mark, p - mark))) 
    }
	goto st43;
tr80:
#line 58 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("lookup", Qnil) 
    }
	goto st43;
tr85:
#line 51 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qfalse) }
	goto st43;
tr89:
#line 49 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qnil) }
	goto st43;
tr93:
#line 50 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qtrue) }
	goto st43;
st43:
	if ( ++p == pe )
		goto _test_eof43;
case 43:
#line 1680 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 46 )
		goto st16;
	goto st0;
tr19:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st44;
st44:
	if ( ++p == pe )
		goto _test_eof44;
case 44:
#line 1694 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
tr20:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st45;
st45:
	if ( ++p == pe )
		goto _test_eof45;
case 45:
#line 1719 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 97: goto st46;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 98 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st46:
	if ( ++p == pe )
		goto _test_eof46;
case 46:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 108: goto st47;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st47:
	if ( ++p == pe )
		goto _test_eof47;
case 47:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 115: goto st48;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st48:
	if ( ++p == pe )
		goto _test_eof48;
case 48:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 101: goto st49;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st49:
	if ( ++p == pe )
		goto _test_eof49;
case 49:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr85;
		case 95: goto st44;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
tr21:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st50;
st50:
	if ( ++p == pe )
		goto _test_eof50;
case 50:
#line 1820 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 105: goto st51;
		case 117: goto st53;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st51:
	if ( ++p == pe )
		goto _test_eof51;
case 51:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 108: goto st52;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st52:
	if ( ++p == pe )
		goto _test_eof52;
case 52:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr89;
		case 95: goto st44;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st53:
	if ( ++p == pe )
		goto _test_eof53;
case 53:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 108: goto st51;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
tr22:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st54;
st54:
	if ( ++p == pe )
		goto _test_eof54;
case 54:
#line 1903 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 114: goto st55;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st55:
	if ( ++p == pe )
		goto _test_eof55;
case 55:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 117: goto st56;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st56:
	if ( ++p == pe )
		goto _test_eof56;
case 56:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr80;
		case 95: goto st44;
		case 101: goto st57;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
st57:
	if ( ++p == pe )
		goto _test_eof57;
case 57:
	switch( (*p) ) {
		case 45: goto st44;
		case 46: goto tr93;
		case 95: goto st44;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st44;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st44;
	} else
		goto st44;
	goto st0;
tr4:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st58;
st58:
	if ( ++p == pe )
		goto _test_eof58;
case 58:
#line 1985 "./ext/liquid/liquid_ext.c"
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st95;
	goto st0;
tr5:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st95;
st95:
	if ( ++p == pe )
		goto _test_eof95;
case 95:
#line 1999 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 46: goto st59;
		case 91: goto tr143;
	}
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st95;
	goto st0;
st59:
	if ( ++p == pe )
		goto _test_eof59;
case 59:
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st96;
	goto st0;
st96:
	if ( ++p == pe )
		goto _test_eof96;
case 96:
	switch( (*p) ) {
		case 46: goto tr144;
		case 91: goto tr145;
	}
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st96;
	goto st0;
tr6:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st97;
st97:
	if ( ++p == pe )
		goto _test_eof97;
case 97:
#line 2035 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st60:
	if ( ++p == pe )
		goto _test_eof60;
case 60:
	if ( (*p) == 93 )
		goto tr97;
	goto tr96;
tr96:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st61;
st61:
	if ( ++p == pe )
		goto _test_eof61;
case 61:
#line 2068 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 93 )
		goto tr99;
	goto st61;
tr99:
#line 68 "./ext/liquid/liquid_ext.rl"
	{
      VALUE body = rb_str_new(mark, p - mark);
      liquid_context_parse_impl(body, tokens);
    }
	goto st98;
st98:
	if ( ++p == pe )
		goto _test_eof98;
case 98:
#line 2083 "./ext/liquid/liquid_ext.c"
	if ( (*p) == 93 )
		goto tr99;
	goto st61;
tr97:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st62;
st62:
	if ( ++p == pe )
		goto _test_eof62;
case 62:
#line 2097 "./ext/liquid/liquid_ext.c"
	goto st61;
tr8:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st99;
st99:
	if ( ++p == pe )
		goto _test_eof99;
case 99:
#line 2109 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 97: goto st100;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 98 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st100:
	if ( ++p == pe )
		goto _test_eof100;
case 100:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 108: goto st101;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st101:
	if ( ++p == pe )
		goto _test_eof101;
case 101:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 115: goto st102;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st102:
	if ( ++p == pe )
		goto _test_eof102;
case 102:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 101: goto st103;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st103:
	if ( ++p == pe )
		goto _test_eof103;
case 103:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr153;
		case 91: goto tr154;
		case 95: goto st97;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
tr9:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st104;
st104:
	if ( ++p == pe )
		goto _test_eof104;
case 104:
#line 2215 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 105: goto st105;
		case 117: goto st107;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st105:
	if ( ++p == pe )
		goto _test_eof105;
case 105:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 108: goto st106;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st106:
	if ( ++p == pe )
		goto _test_eof106;
case 106:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr158;
		case 91: goto tr159;
		case 95: goto st97;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st107:
	if ( ++p == pe )
		goto _test_eof107;
case 107:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 108: goto st105;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
tr10:
#line 11 "./ext/liquid/liquid_ext.rl"
	{
    mark = p;
  }
	goto st108;
st108:
	if ( ++p == pe )
		goto _test_eof108;
case 108:
#line 2302 "./ext/liquid/liquid_ext.c"
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 114: goto st109;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st109:
	if ( ++p == pe )
		goto _test_eof109;
case 109:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 117: goto st110;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st110:
	if ( ++p == pe )
		goto _test_eof110;
case 110:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr147;
		case 91: goto tr148;
		case 95: goto st97;
		case 101: goto st111;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
st111:
	if ( ++p == pe )
		goto _test_eof111;
case 111:
	switch( (*p) ) {
		case 45: goto st97;
		case 46: goto tr163;
		case 91: goto tr164;
		case 95: goto st97;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto st97;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto st97;
	} else
		goto st97;
	goto st0;
	}
	_test_eof2: cs = 2; goto _test_eof; 
	_test_eof63: cs = 63; goto _test_eof; 
	_test_eof3: cs = 3; goto _test_eof; 
	_test_eof64: cs = 64; goto _test_eof; 
	_test_eof4: cs = 4; goto _test_eof; 
	_test_eof5: cs = 5; goto _test_eof; 
	_test_eof6: cs = 6; goto _test_eof; 
	_test_eof7: cs = 7; goto _test_eof; 
	_test_eof8: cs = 8; goto _test_eof; 
	_test_eof9: cs = 9; goto _test_eof; 
	_test_eof10: cs = 10; goto _test_eof; 
	_test_eof11: cs = 11; goto _test_eof; 
	_test_eof12: cs = 12; goto _test_eof; 
	_test_eof13: cs = 13; goto _test_eof; 
	_test_eof14: cs = 14; goto _test_eof; 
	_test_eof15: cs = 15; goto _test_eof; 
	_test_eof16: cs = 16; goto _test_eof; 
	_test_eof17: cs = 17; goto _test_eof; 
	_test_eof18: cs = 18; goto _test_eof; 
	_test_eof19: cs = 19; goto _test_eof; 
	_test_eof65: cs = 65; goto _test_eof; 
	_test_eof20: cs = 20; goto _test_eof; 
	_test_eof66: cs = 66; goto _test_eof; 
	_test_eof21: cs = 21; goto _test_eof; 
	_test_eof22: cs = 22; goto _test_eof; 
	_test_eof67: cs = 67; goto _test_eof; 
	_test_eof23: cs = 23; goto _test_eof; 
	_test_eof68: cs = 68; goto _test_eof; 
	_test_eof24: cs = 24; goto _test_eof; 
	_test_eof69: cs = 69; goto _test_eof; 
	_test_eof70: cs = 70; goto _test_eof; 
	_test_eof71: cs = 71; goto _test_eof; 
	_test_eof72: cs = 72; goto _test_eof; 
	_test_eof73: cs = 73; goto _test_eof; 
	_test_eof74: cs = 74; goto _test_eof; 
	_test_eof75: cs = 75; goto _test_eof; 
	_test_eof76: cs = 76; goto _test_eof; 
	_test_eof77: cs = 77; goto _test_eof; 
	_test_eof78: cs = 78; goto _test_eof; 
	_test_eof79: cs = 79; goto _test_eof; 
	_test_eof80: cs = 80; goto _test_eof; 
	_test_eof81: cs = 81; goto _test_eof; 
	_test_eof25: cs = 25; goto _test_eof; 
	_test_eof82: cs = 82; goto _test_eof; 
	_test_eof83: cs = 83; goto _test_eof; 
	_test_eof84: cs = 84; goto _test_eof; 
	_test_eof85: cs = 85; goto _test_eof; 
	_test_eof86: cs = 86; goto _test_eof; 
	_test_eof87: cs = 87; goto _test_eof; 
	_test_eof88: cs = 88; goto _test_eof; 
	_test_eof89: cs = 89; goto _test_eof; 
	_test_eof90: cs = 90; goto _test_eof; 
	_test_eof91: cs = 91; goto _test_eof; 
	_test_eof92: cs = 92; goto _test_eof; 
	_test_eof93: cs = 93; goto _test_eof; 
	_test_eof94: cs = 94; goto _test_eof; 
	_test_eof26: cs = 26; goto _test_eof; 
	_test_eof27: cs = 27; goto _test_eof; 
	_test_eof28: cs = 28; goto _test_eof; 
	_test_eof29: cs = 29; goto _test_eof; 
	_test_eof30: cs = 30; goto _test_eof; 
	_test_eof31: cs = 31; goto _test_eof; 
	_test_eof32: cs = 32; goto _test_eof; 
	_test_eof33: cs = 33; goto _test_eof; 
	_test_eof34: cs = 34; goto _test_eof; 
	_test_eof35: cs = 35; goto _test_eof; 
	_test_eof36: cs = 36; goto _test_eof; 
	_test_eof37: cs = 37; goto _test_eof; 
	_test_eof38: cs = 38; goto _test_eof; 
	_test_eof39: cs = 39; goto _test_eof; 
	_test_eof40: cs = 40; goto _test_eof; 
	_test_eof41: cs = 41; goto _test_eof; 
	_test_eof42: cs = 42; goto _test_eof; 
	_test_eof43: cs = 43; goto _test_eof; 
	_test_eof44: cs = 44; goto _test_eof; 
	_test_eof45: cs = 45; goto _test_eof; 
	_test_eof46: cs = 46; goto _test_eof; 
	_test_eof47: cs = 47; goto _test_eof; 
	_test_eof48: cs = 48; goto _test_eof; 
	_test_eof49: cs = 49; goto _test_eof; 
	_test_eof50: cs = 50; goto _test_eof; 
	_test_eof51: cs = 51; goto _test_eof; 
	_test_eof52: cs = 52; goto _test_eof; 
	_test_eof53: cs = 53; goto _test_eof; 
	_test_eof54: cs = 54; goto _test_eof; 
	_test_eof55: cs = 55; goto _test_eof; 
	_test_eof56: cs = 56; goto _test_eof; 
	_test_eof57: cs = 57; goto _test_eof; 
	_test_eof58: cs = 58; goto _test_eof; 
	_test_eof95: cs = 95; goto _test_eof; 
	_test_eof59: cs = 59; goto _test_eof; 
	_test_eof96: cs = 96; goto _test_eof; 
	_test_eof97: cs = 97; goto _test_eof; 
	_test_eof60: cs = 60; goto _test_eof; 
	_test_eof61: cs = 61; goto _test_eof; 
	_test_eof98: cs = 98; goto _test_eof; 
	_test_eof62: cs = 62; goto _test_eof; 
	_test_eof99: cs = 99; goto _test_eof; 
	_test_eof100: cs = 100; goto _test_eof; 
	_test_eof101: cs = 101; goto _test_eof; 
	_test_eof102: cs = 102; goto _test_eof; 
	_test_eof103: cs = 103; goto _test_eof; 
	_test_eof104: cs = 104; goto _test_eof; 
	_test_eof105: cs = 105; goto _test_eof; 
	_test_eof106: cs = 106; goto _test_eof; 
	_test_eof107: cs = 107; goto _test_eof; 
	_test_eof108: cs = 108; goto _test_eof; 
	_test_eof109: cs = 109; goto _test_eof; 
	_test_eof110: cs = 110; goto _test_eof; 
	_test_eof111: cs = 111; goto _test_eof; 

	_test_eof: {}
	if ( p == eof )
	{
	switch ( cs ) {
	case 98: 
#line 15 "./ext/liquid/liquid_ext.rl"
	{
    EMIT("lookup", Qnil)
  }
	break;
	case 67: 
#line 19 "./ext/liquid/liquid_ext.rl"
	{
    EMIT("call", Qnil)
  }
	break;
	case 65: 
#line 22 "./ext/liquid/liquid_ext.rl"
	{
    EMIT("range", Qnil)
  }
	break;
	case 95: 
#line 41 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Integer"), 1, rb_str_new(mark, p - mark))); 
    }
	break;
	case 96: 
#line 45 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_funcall(rb_cObject, rb_intern("Float"), 1, rb_str_new(mark, p - mark))) 
    }
	break;
	case 106: 
#line 49 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qnil) }
	break;
	case 111: 
#line 50 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qtrue) }
	break;
	case 103: 
#line 51 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", Qfalse) }
	break;
	case 63: 
	case 64: 
#line 53 "./ext/liquid/liquid_ext.rl"
	{ EMIT("id", rb_str_new(mark + 1, p - mark - 2)) }
	break;
	case 97: 
	case 99: 
	case 100: 
	case 101: 
	case 102: 
	case 104: 
	case 105: 
	case 107: 
	case 108: 
	case 109: 
	case 110: 
#line 58 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("lookup", Qnil) 
    }
	break;
	case 73: 
	case 86: 
#line 84 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("first"))
    }
	break;
	case 77: 
	case 90: 
#line 88 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("last"))
    }
	break;
	case 81: 
	case 94: 
#line 92 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("buildin", rb_str_new2("size"))      
    }
	break;
	case 66: 
	case 68: 
	case 69: 
	case 70: 
	case 71: 
	case 72: 
	case 74: 
	case 75: 
	case 76: 
	case 78: 
	case 79: 
	case 80: 
	case 82: 
	case 83: 
	case 84: 
	case 85: 
	case 87: 
	case 88: 
	case 89: 
	case 91: 
	case 92: 
	case 93: 
#line 96 "./ext/liquid/liquid_ext.rl"
	{ 
      EMIT("id", rb_str_new(mark, p - mark))
      EMIT("call", Qnil) 
    }
	break;
#line 2607 "./ext/liquid/liquid_ext.c"
	}
	}

	_out: {}
	}

#line 137 "./ext/liquid/liquid_ext.rl"
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
