#ifndef LIQUID_EXT_H
#define LIQUID_EXT_H

#include <stdbool.h>
#include <ctype.h>
#include <ruby.h>

#include "tokenizer.h"
#include "block.h"
#include "slice.h"
#include "utils.h"

extern ID intern_new;
extern VALUE mLiquid;
extern VALUE cLiquidTemplate, cLiquidTag, cLiquidVariable;

#endif
