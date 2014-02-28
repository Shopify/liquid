#include "liquid_ext.h"

VALUE cLiquidStringSlice;

static void mark_slice(void *ptr)
{
    if (!ptr)
        return;
    struct string_slice *slice = ptr;
    rb_gc_mark(slice->source);
}

static void free_slice(void *ptr)
{
    struct string_slice *slice = ptr;
    xfree(slice);
}

VALUE liquid_string_slice_new(char *str, long length)
{
    return rb_funcall(cLiquidStringSlice, intern_new, 3, rb_str_new(str, length), INT2FIX(0), INT2FIX(length));
}

static VALUE rb_allocate(VALUE klass)
{
    struct string_slice *slice;
    VALUE obj = Data_Make_Struct(klass, struct string_slice, mark_slice, free_slice, slice);
    return obj;
}

static VALUE rb_initialize(VALUE self, VALUE source, VALUE offset_value, VALUE length_value)
{
    long offset = rb_fix2int(offset_value);
    long length = rb_fix2int(length_value);
    if (length < 0)
        rb_raise(rb_eArgError, "negative string length");
    if (offset < 0)
        rb_raise(rb_eArgError, "negative string offset");

    if (TYPE(source) == T_DATA && RBASIC_CLASS(source) == cLiquidStringSlice) {
        struct string_slice *source_slice = DATA_PTR(source);
        source = source_slice->source;
        offset += source_slice->str - RSTRING_PTR(source);
    } else {
        source = rb_string_value(&source);
        source = rb_str_dup_frozen(source);
    }

    struct string_slice *slice;
    Data_Get_Struct(self, struct string_slice, slice);
    slice->source = source;
    slice->str = RSTRING_PTR(source) + offset;
    slice->length = length;
    if (length > RSTRING_LEN(source) - offset)
        rb_raise(rb_eArgError, "slice bounds outside source string bounds");

    return Qnil;
}

static VALUE rb_slice_to_str(VALUE self)
{
    struct string_slice *slice;
    Data_Get_Struct(self, struct string_slice, slice);

    VALUE source = slice->source;
    if (slice->str == RSTRING_PTR(source) && slice->length == RSTRING_LEN(source))
        return source;

    source = rb_str_new(slice->str, slice->length);
    slice->source = source;
    slice->str = RSTRING_PTR(source);
    return source;
}

static VALUE rb_slice_slice(VALUE self, VALUE offset, VALUE length)
{
    return rb_funcall(cLiquidStringSlice, intern_new, 3, self, offset, length);
}

static VALUE rb_slice_length(VALUE self)
{
    struct string_slice *slice;
    Data_Get_Struct(self, struct string_slice, slice);
    return INT2FIX(slice->length);
}

static VALUE rb_slice_equal(VALUE self, VALUE other)
{
    struct string_slice *this_slice;
    Data_Get_Struct(self, struct string_slice, this_slice);

    char *other_str;
    long other_length;
    if (TYPE(other) == T_DATA && RBASIC_CLASS(other) == cLiquidStringSlice) {
        struct string_slice *other_slice = DATA_PTR(other);
        other_str = other_slice->str;
        other_length = other_slice->length;
    } else {
        other = rb_string_value(&other);
        other_length = RSTRING_LEN(other);
        other_str = RSTRING_PTR(other);
    }
    bool equal = this_slice->length == other_length && !memcmp(this_slice->str, other_str, other_length);
    return equal ? Qtrue : Qfalse;
}

static VALUE rb_slice_inspect(VALUE self)
{
    VALUE quoted = rb_str_inspect(rb_slice_to_str(self));
    return rb_sprintf("#<Liquid::StringSlice: %.*s>", (int)RSTRING_LEN(quoted), RSTRING_PTR(quoted));
}

void init_liquid_string_slice()
{
    cLiquidStringSlice = rb_define_class_under(mLiquid, "StringSlice", rb_cObject);
    rb_define_alloc_func(cLiquidStringSlice, rb_allocate);
    rb_define_method(cLiquidStringSlice, "initialize", rb_initialize, 3);
    rb_define_method(cLiquidStringSlice, "==", rb_slice_equal, 1);
    rb_define_method(cLiquidStringSlice, "length", rb_slice_length, 0);
    rb_define_alias(cLiquidStringSlice,  "size", "length");
    rb_define_method(cLiquidStringSlice, "slice", rb_slice_slice, 2);
    rb_define_method(cLiquidStringSlice, "to_str", rb_slice_to_str, 0);
    rb_define_alias(cLiquidStringSlice,  "to_s", "to_str");
    rb_define_method(cLiquidStringSlice, "inspect", rb_slice_inspect, 0);
}
