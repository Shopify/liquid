#ifndef LIQUID_UTILS_H
#define LIQUID_UTILS_H

void raise_type_error(VALUE expected, VALUE got);
void check_class(VALUE klass);
void *obj_get_data_ptr(VALUE obj, VALUE klass);

#endif
