#include <ruby.h>

static VALUE rb_Liquid;
static VALUE rb_Parser;

VALUE liquid_context_parse_impl(VALUE text);

void Init_liquid_ext()
{
  rb_Liquid = rb_define_module("Liquid");
  rb_Parser = rb_define_class_under(rb_Liquid, "Parser", rb_cObject);
  rb_define_singleton_method(rb_Parser, "parse", liquid_context_parse_impl, 1);  
}
