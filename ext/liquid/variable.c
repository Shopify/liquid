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

static int skip_whitespace(char * str, int len) 
{
  int i = 0; char * ptr = str;
  while (i < len && isspace(*ptr))
    {i++; ptr++;}
  return i;
}

static char * get_quoted_fragment(char * cursor, int len, VALUE self) 
{
  int count = 0; int start = -1, end = -1; char quoted = -1;
  while (count < len) {
    
    switch (cursor[count]) {
      case '"': 
        if (start == -1) {start = count; quoted = '"';}
        else if (cursor[start] == '"') {end = count; goto form_name;}
        else if (quoted == -1) quoted = '"';
        else if (quoted == '"') quoted = -1;
        break;
      case '\'':
        if (start == -1) {start = count; quoted = '\'';}
        else if (cursor[start] == '\'') {end = count; goto form_name;}
        else if (quoted == -1) quoted = '\'';
        else if (quoted == '\'') quoted = -1;
        break;
      case '|':
      case ',':
      case '\n':
      case '\r':
      case '\f':
      case '\t':
      case '\v':
      case ' ': 
        if (start != -1 && quoted == -1) {end = count-1; goto form_name;} 
        break;
      default: 
        if (start == -1) start = count; 
        break;
    }
    count++;
  }
  if (count == len && start != -1 && end == -1) end = len-1;

  form_name:
  if (end > start) {
    rb_iv_set(self, "@name", rb_str_new(&cursor[start], end-start+1));
    return &cursor[end+1];
  } else {
    rb_iv_set(self, "@name", Qnil);
    return NULL;
  }
}

static VALUE get_filters(char * cursor, int len, VALUE self) {
  int count = 0;

  while(count<len) {
    if (cursor[count] == '|') {
      count += skip_whitespace(&cursor[count]+1, len-count);

    }
  }
  return self;
}

static void rb_variable_lax_parse(VALUE self, VALUE m) 
{
  char * markup = RSTRING_PTR(m);
  int markup_len = RSTRING_LEN(m);

  char * cursor = markup; int count = 0; VALUE filters;

  /* Extract name */
  count += skip_whitespace(markup, markup_len); 
  cursor = markup+count;
  cursor = get_quoted_fragment(cursor, markup_len-count, self);

  if (cursor == NULL) {filters = rb_ary_new(); rb_iv_set(self, "@filters", filters);}
  else 
  {
    /* Extract filters */
    filters = get_filters(cursor, (markup-cursor)/sizeof(char), self);
  }

}

void init_liquid_variable()
{
    cLiquidVariable = rb_define_class_under(mLiquid, "Variable", rb_cObject);
    rb_define_alloc_func(cLiquidVariable, rb_variable_allocate);
    rb_define_method(cLiquidVariable, "lax_parse", rb_variable_lax_parse, 1);
}