#ifndef LIQUID_SLICE_H
#define LIQUID_SLICE_H

extern VALUE cLiquidStringSlice;

struct string_slice {
    VALUE source;
    char *str;
    long length;
};

VALUE liquid_string_slice_new(char *str, long length);

void init_liquid_string_slice();

#define STRING_SLICE_GET_STRUCT(obj) ((struct string_slice *)obj_get_data_ptr(obj, cLiquidStringSlice))

#endif
