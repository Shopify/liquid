#include "liquid_ext.h"

VALUE mLiquid;
VALUE cLiquidTemplate, cLiquidTag, cLiquidVariable;

void Init_liquid(void)
{
    mLiquid = rb_define_module("Liquid");
    cLiquidTemplate = rb_define_class_under(mLiquid, "Template", rb_cObject);
    cLiquidTag = rb_define_class_under(mLiquid, "Tag", rb_cObject);
    cLiquidVariable = rb_define_class_under(mLiquid, "Variable", rb_cObject);

    init_liquid_tokenizer();
    init_liquid_block();
}
