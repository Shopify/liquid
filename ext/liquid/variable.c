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

// static void rb_variable_lax_parse(VALUE self, VALUE markup) 
// {  
//   struct liquid_variable *variable;
//   variable->markup = RSTRING_PTR(markup);
//   variable->markup_len = RSTRING_LEN(markup);

//   regex_t regex, regex_f_args; 
//   int reti; 
//   regmatch_t match[3], f_match[5], f_arg_match[5];

//   regcomp(&regex, "\\s*(((\"[^\"]*\"|'[^']*')|([^\\s,\\|'\"]|(\"[^\"]*\"|'[^']*'))+))(.*)", REG_EXTENDED | REG_ICASE);
//   // regcomp(&regex, "\\s*((?:(?:\"[^\"]*\"|'[^']*')|(?:[^\\s,\\|'\"]|(?:\"[^\"]*\"|'[^']*'))+))(.*)", REG_ICASE | REG_ECMASCRIPT;
  
//   reti = regexec(&regex, variable->markup, 3, match, 0);

//   if( !reti ){
//     /* Extract name */
//     // printf("\nWith the whole expression, a matched substring %.*s is found at position %d to %d. "
//     //          " and rest at %.*s is found at position %d to %d.\n",
//     //          match[1].rm_eo - match[1].rm_so, &variable->markup[match[1].rm_so], match[1].rm_so, match[1].rm_eo,
//     //          match[2].rm_eo - match[2].rm_so, &variable->markup[match[2].rm_so], match[2].rm_so, match[2].rm_eo);
    
//     variable->name = &variable->markup[match[1].rm_so];
//     variable->name_len = match[1].rm_eo - match[1].rm_so;

//     rb_iv_set(self, "@name", rb_str_new(variable->name, variable->name_len));

//     /* Extract filters */
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
//   }
// }

static int skip_whitespace(char * str, int len) 
{
  int i = 0; char * ptr = str;
  while (i < len && (*ptr == " " || *ptr == "\t" || *ptr == "\n" || *ptr == "\v" || *ptr == "\f" || *ptr == "\r"))
    i++;
  return i;
}

static char * cpy_string(char * str, int len) 
{
  char * s = malloc(len*sizeof(char) + 1);
  int i = 0;
  while (i<len) s[i] = str[i];
  s[i] = '\0';
  return s;
}

static char * get_quoted_fragment(char * cursor, int len, char * name) 
{
  int count = 0; int start = -1, end = -1;
  while (count < len) {
    
    switch (cursor[count]) {
      case '"': 
        if (start == -1) start = count;
        else {end = count+1; goto form_name;}
        break;
      case '\'':
        if (start == -1) start = count;
        else {end = count+1; goto form_name;}
        break;
      default: 
        if (cursor[count] != '|' && cursor[count] != ':' && cursor[count] != ',' && cursor[count] != ' ' &&
            cursor[count] != '\n' && cursor[count] != '\v' && cursor[count] != '\t' && cursor[count] != '\f' && cursor[count] != '\r')
          { if (start == -1) start = count; }
        else 
          { end = count+1; goto form_name;}
    }
    count++;
  }
form_name:
  if (end > start) name = cpy_string(&cursor[start], end-start);

  if (end != -1) return &cursor[end];
  else return NULL;
}

static void rb_variable_lax_parse_new(VALUE self, VALUE m) 
{
  char * markup = RSTRING_PTR(m);
  int markup_len = RSTRING_LEN(m);

  char * cursor = markup; int count = 0;
  
  /* Extract name */
  char * name;
  count += skip_whitespace(markup, markup_len); cursor = markup+count;
  cursor = get_quoted_fragment(cursor, markup_len-count, name);

  if (name == NULL) rb_iv_set(self, "@name", Qnil);
  else 
  {
    rb_iv_set(self, "@name", rb_str_new2(name));

    /* Extract filters */
  }
}

void init_liquid_variable()
{
    cLiquidVariable = rb_define_class_under(mLiquid, "Variable", rb_cObject);
    rb_define_alloc_func(cLiquidVariable, rb_variable_allocate);
    rb_define_method(cLiquidVariable, "lax_parse", rb_variable_lax_parse_new, 1);
}