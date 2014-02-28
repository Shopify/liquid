#include <ruby.h>

void raise_type_error(VALUE expected, VALUE got)
{
    rb_raise(rb_eTypeError, "wrong argument type %s (expected %s)",
                             rb_class2name(got), rb_class2name(expected));
}

void check_class(VALUE obj, int type, VALUE klass)
{
    Check_Type(obj, type);
    VALUE obj_klass = RBASIC_CLASS(obj);
    if (obj_klass != klass)
        raise_type_error(klass, obj_klass);
}

void *obj_get_data_ptr(VALUE obj, VALUE klass)
{
    check_class(obj, T_DATA, klass);
    return DATA_PTR(obj);
}
