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
  while (i < len && !isspace(*ptr))
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
        if (cursor[count] != '|' && cursor[count] != ':' && cursor[count] != ',' && cursor[count] != ' ' && !isspace(cursor[count]))
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