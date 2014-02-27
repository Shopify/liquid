#include "liquid_ext.h"

VALUE mLiquid;

void Init_liquid(void)
{
    mLiquid = rb_define_module("Liquid");
    init_liquid_tokenizer();
}
