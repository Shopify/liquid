#include "liquid_ext.h"

VALUE cLiquidVariable;
extern VALUE mLiquid;

static void free_variable(void *ptr)
{
    struct liquid_variable *variable = ptr;
    xfree(variable);
}

static VALUE rb_variable_allocate(VALUE klass)
{
    VALUE obj;
    struct liquid_variable *variable;

    obj = Data_Make_Struct(klass, struct liquid_variable, NULL, free_variable, variable);
    return obj;
}

static void rb_variable_lax_parse(VALUE self, VALUE markup) 
{  
  struct liquid_variable *variable;
  variable->markup = RSTRING_PTR(markup);
  variable->markup_len = RSTRING_LEN(markup);

  regex_t regex, regex_f_args; 
  int reti; 
  regmatch_t match[3], f_match[5], f_arg_match[5];

  regcomp(&regex, "\\s*(((\"[^\"]*\"|'[^']*')|([^\\s,\\|'\"]|(\"[^\"]*\"|'[^']*'))+))(.*)", REG_EXTENDED | REG_ICASE);
  // regcomp(&regex, "\\s*((?:(?:\"[^\"]*\"|'[^']*')|(?:[^\\s,\\|'\"]|(?:\"[^\"]*\"|'[^']*'))+))(.*)", REG_ICASE | REG_ECMASCRIPT;
  
  reti = regexec(&regex, variable->markup, 3, match, 0);

  if( !reti ){
    /* Extract name */
    printf("\nWith the whole expression, a matched substring %.*s is found at position %d to %d. "
             " and rest at %.*s is found at position %d to %d.\n",
             match[1].rm_eo - match[1].rm_so, &variable->markup[match[1].rm_so], match[1].rm_so, match[1].rm_eo,
             match[2].rm_eo - match[2].rm_so, &variable->markup[match[2].rm_so], match[2].rm_so, match[2].rm_eo);
    
    variable->name = &variable->markup[match[1].rm_so];
    variable->name_len = match[1].rm_eo - match[1].rm_so;

    rb_iv_set(self, "@name", rb_str_new(variable->name, variable->name_len));

    /* Extract filters */
//     char * cursor = &variable->markup[match[2].rm_so]; int size = match[2].rm_eo - match[2].rm_so;
//     while (cursor++ < &variable->markup[match[2].rm_eo]) {
//       if (*cursor == ' ' || *cursor == '\n' || *cursor == '\f' || *cursor == '\t' || *cursor == '\r' || *cursor == '\v') continue;
//       else if (*cursor == '|') {
//         while (cursor++ < &variable->markup[match[2].rm_eo])
//          if (*cursor == ' ' || *cursor == '\n' || *cursor == '\f' || *cursor == '\t' || *cursor == '\r' || *cursor == '\v') continue;
//          else goto filters_present;
//       } else return;
//     }
// filters_present:
//     if (cursor < &variable->markup[match[2].rm_eo]) {
//       regcomp(&regex, "((|)|(\\s*(((\"[^\"]*\"|'[^']*')|([^\\s,\\|'\"]|(\"[^\"]*\"|'[^']*'))+)|(,))\\s*)+)", REG_EXTENDED | REG_ICASE);
//       reti = regexec(&regex, cursor, 5, f_match, 0);
//       regcomp(&regex_f_args, "((:)|(,))\\s*((\\w+\\s*\\:\\s*)?((\"[^\"]*\"|'[^']*')|([^\\s,\\|'\"]|(\"[^\"]*\"|'[^']*'))+))", REG_EXTENDED | REG_ICASE);

//       if ( !reti ) {
//         VALUE filters_array = rb_ary_new();

//         int i = 1;
//         while(i < 5) {
//           // VALUE filter_data = rb_ary_new();

//           char * filter = f_match[i].rm_so;
          
//           // get filtername

//            // get filter args into an array
//           // regexec(&regex, filter, 3, f_arg_match, 0);

         
//           rb_ary_push(filters_array, ID2SYM(rb_intern(filter)));
//           // rb_ary_push(filters_array, filter_data);
//           i++;
//         }

//         rb_iv_set(self, "@filters", filters_array);
//       }
//     }


  }
}

// static void rb_easy_parse(VALUE self)
// {
//   struct liquid_variable *variable;
//   Data_Get_Struct(self, struct liquid_variable, variable);

//   regex_t regex; int reti; regmatch_t match[2];
//   reti = regcomp(&regex, " *(\\w+(\\.\\w+)*) *", REG_EXTENDED);
//   reti = regexec(&regex, variable->markup, 2, match, 0);
//   if( !reti ){
//     variable->name = &variable->markup[match[1].rm_so];
//     variable->name_len = match[1].rm_eo - match[1].rm_so;

//     return;
//   }

//   VALUE p = rb_funcall(rb_path2class("Liquid::Parser"), rb_intern("new"), 1, rb_str_new(variable->markup, variable->markup_len));

//   if (rb_funcall(p, rb_intern("look"), 1, ID2SYM(rb_intern("pipe")) ))
//   {    
//     variable->name = NULL; variable->name_len = 0;
//   } 
//   else
//   {
//     VALUE val = rb_funcall(p, rb_intern("expression"), 0);
//     variable->name = RSTRING_PTR(val);
//     variable->name_len = RSTRING_LEN(val);    
//   }
// }

// static VALUE rb_variable_initialize(VALUE self, VALUE markup)
// {
//     Check_Type(markup, T_STRING);

//     rb_iv_set(self, "@filters", rb_ary_new());
//     rb_iv_set(self, "@markup", markup);

//     // FIXME need to be able to accept :error_mode parameter when creating
//     VALUE val = rb_funcall(rb_path2class("Liquid::Template"), rb_intern("error_mode"), 0);

//     lax_parse(self, markup);

//     // if (val == ID2SYM(rb_intern("strict"))) rb_funcall(self, rb_intern("strict_parse"), 1, markup);
//     // else if (val == ID2SYM(rb_intern("lax"))) lax_parse(self, markup);
//     // FIXME handle :warn case

//     return self;
// }

void init_liquid_variable()
{
    cLiquidVariable = rb_define_class_under(mLiquid, "Variable", rb_cObject);
    rb_define_alloc_func(cLiquidVariable, rb_variable_allocate);
    rb_define_method(cLiquidVariable, "lax_parse", rb_variable_lax_parse, 1);
}