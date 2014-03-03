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

static inline int skip_whitespace(char * str, int len) 
{
  int skipped = 0; char * ptr = str;
  while (skipped < len && isspace(*ptr))
    {skipped++; ptr++;}
  return skipped;
}

static char * get_quoted_fragment(char * str, int len, int * ret_size, int * end_offset) 
{
  int p = 0; /* Current position in string */
  int start = -1, end = -1; /* Start and end indices for the found string */
  char quoted_by = -1; /* Is the current part of string quoted by a single or double quote? If so 
                          ignore any special chars */

  while (p < len) {
    
    switch (str[p]) {
      case '"': 
        if (start == -1) {start = p; quoted_by = '"';}
        else if (str[start] == '"') {end = p; goto quoted_fragment_found;}
        else if (quoted_by == -1) quoted_by = '"';
        else if (quoted_by == '"') quoted_by = -1;
        break;
      case '\'':
        if (start == -1) {start = p; quoted_by = '\'';}
        else if (str[start] == '\'') {end = p; goto quoted_fragment_found;}
        else if (quoted_by == -1) quoted_by = '\'';
        else if (quoted_by == '\'') quoted_by = -1;
        break;
      case '|':
      case ',':
      case '\n':
      case '\r':
      case '\f':
      case '\t':
      case '\v':
      case ' ': 
        if (start != -1 && quoted_by == -1) {end = p-1; goto quoted_fragment_found;} 
        break;
      default: 
        if (start == -1) start = p; 
        break;
    }
    p++;
  }
  if (p == len && start != -1 && end == -1) end = len-1;

quoted_fragment_found:
  if (end > start) {
    *ret_size = end-start+1;
    *end_offset = end+1;
    return &str[start];
  } else {
    *ret_size = 0;
    return NULL;
  }
}

static VALUE get_filters(char * str, int len, VALUE self) {
  VALUE filters_arr = rb_ary_new(); 

  int p = 0; 
  int ret_size, end_offset; 
  char * f;

  while(p<len) {
    if (str[p] == '|') {
      VALUE filter = rb_ary_new();
      VALUE f_args = rb_ary_new();

      p += skip_whitespace(&str[p+1], len-p-1);
      f = get_quoted_fragment(&str[p], len-p, &ret_size, &end_offset);
      p += end_offset-1;

      if (f) {
        if (f[ret_size-1] == ':') ret_size--;
        rb_ary_push(filter, rb_str_new(f, ret_size));
      }

      /* Check for filter arguments */
      // do {
      //   p += skip_whitespace(&str[p+1], len-p-1);

      //   if (str[p] == '|') 
      //   f = get_quoted_fragment(&str[p], len-p, &ret_size, &end_offset);
      //   p += end_offset-1;
      //   p += skip_whitespace(&str[p+1], len-p-1);

      //   if (f) rb_ary_push(f_args, rb_str_new(f, ret_size));
      // } while (str[p] == ',' || str[p] == ':');

      rb_ary_push(filter, f_args);

      /* Add to filters_arr array */
      rb_ary_push(filters_arr, filter);
    }
    p++;
  }
  return filters_arr;
}

static VALUE rb_variable_lax_parse(VALUE self, VALUE m) 
{
  char * markup = RSTRING_PTR(m);
  int markup_len = RSTRING_LEN(m);

  char * cursor = markup; int cursor_pos = 0; 
  VALUE filters_arr; 
  int size, end_offset;

  /* Extract name */
  cursor_pos += skip_whitespace(markup, markup_len); 
  cursor = markup + cursor_pos;
  cursor = get_quoted_fragment(cursor, markup_len - cursor_pos, &size, &end_offset);

  if (cursor == NULL) {
    rb_iv_set(self, "@name", Qnil);
    filters_arr = rb_ary_new(); 
    rb_iv_set(self, "@filters", filters_arr);
  }
  else 
  {
    rb_iv_set(self, "@name", rb_str_new(cursor, size));

    /* Extract filters */
    if (end_offset < markup_len) {
      cursor = &markup[end_offset];
      filters_arr = get_filters(cursor, markup_len - end_offset, self);
      rb_iv_set(self, "@filters", filters_arr);
    }
  }
  return filters_arr;
}

void init_liquid_variable()
{
    cLiquidVariable = rb_define_class_under(mLiquid, "Variable", rb_cObject);
    rb_define_alloc_func(cLiquidVariable, rb_variable_allocate);
    rb_define_method(cLiquidVariable, "lax_parse", rb_variable_lax_parse, 1);
}