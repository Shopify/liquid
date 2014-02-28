#include "liquid_ext.h"

VALUE mLiquid;
VALUE cLiquidTemplate, cLiquidTag, cLiquidVariable;
ID intern_new;

void Init_liquid(void)
{
    intern_new = rb_intern("new");
    mLiquid = rb_define_module("Liquid");
    cLiquidTemplate = rb_define_class_under(mLiquid, "Template", rb_cObject);
    cLiquidTag = rb_define_class_under(mLiquid, "Tag", rb_cObject);
    cLiquidVariable = rb_define_class_under(mLiquid, "Variable", rb_cObject);

    init_liquid_tokenizer();
    init_liquid_block();
    init_liquid_string_slice();
}
