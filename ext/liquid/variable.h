#ifndef LIQUID_VARIABLE_H
#define LIQUID_VARIABLE_H

#include <regex.h>

enum error_mode {
    STRICT,
    LAX,
    WARN
};

struct liquid_variable {
    char *markup; long markup_len;
    char *name; long name_len;
    enum error_mode e_mode;
    char **filters;
    int *filter_len;
};

void init_liquid_variable();

#endif
