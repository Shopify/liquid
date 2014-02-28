#ifndef LIQUID_VARIABLE_H
#define LIQUID_VARIABLE_H

#include <regex.h>

struct liquid_variable {
    char *markup; long markup_len;
    char *name; long name_len;
};

void init_liquid_variable();

#endif
