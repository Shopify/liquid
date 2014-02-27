#include "liquid_ext.h"

VALUE cLiquidTokenizer;
extern VALUE mLiquid;

static void free_tokenizer(void *ptr)
{
    struct liquid_tokenizer *tokenizer = ptr;
    xfree(tokenizer);
}

static VALUE rb_allocate(VALUE klass)
{
    VALUE obj;
    struct liquid_tokenizer *tokenizer;

    obj = Data_Make_Struct(klass, struct liquid_tokenizer, NULL, free_tokenizer, tokenizer);
    return obj;
}

static VALUE rb_initialize(VALUE self, VALUE source)
{
    struct liquid_tokenizer *tokenizer;

    Check_Type(source, T_STRING);
    Data_Get_Struct(self, struct liquid_tokenizer, tokenizer);
    tokenizer->cursor = RSTRING_PTR(source);
    tokenizer->length = RSTRING_LEN(source);
}

void liquid_tokenizer_next(struct liquid_tokenizer *tokenizer, struct token *token)
{
    if (tokenizer->length <= 0) {
        memset(token, 0, sizeof(*token));
        return;
    }
    token->type = TOKEN_STRING;

    char *cursor = tokenizer->cursor;
    char *last = tokenizer->cursor + tokenizer->length - 1;

    while (cursor < last) {
        if (*cursor++ != '{')
            continue;

        char c = *cursor++;
        if (c != '%' && c != '{')
            continue;
        if (cursor - tokenizer->cursor > 2) {
            token->type = TOKEN_STRING;
            cursor -= 2;
            goto found;
        }
        char *incomplete_end = cursor;
        token->type = TOKEN_INVALID;
        if (c == '%') {
            while (cursor < last) {
                if (*cursor++ != '%')
                    continue;
                c = *cursor++;
                while (c == '%' && cursor <= last)
                    c = *cursor++;
                if (c != '}')
                    continue;
                token->type = TOKEN_TAG;
                goto found;
            }
            cursor = incomplete_end;
            goto found;
        } else {
            while (cursor < last) {
                if (*cursor++ != '}')
                    continue;
                if (*cursor++ != '}') {
                    incomplete_end = cursor - 1;
                    continue;
                }
                token->type = TOKEN_VARIABLE;
                goto found;
            }
            cursor = incomplete_end;
            goto found;
        }
    }
    cursor = last + 1;
found:
    token->str = tokenizer->cursor;
    token->length = cursor - tokenizer->cursor;
    tokenizer->cursor += token->length;
    tokenizer->length -= token->length;
}

static VALUE rb_next(VALUE self)
{
    struct liquid_tokenizer *tokenizer;
    Data_Get_Struct(self, struct liquid_tokenizer, tokenizer);

    struct token token;
    liquid_tokenizer_next(tokenizer, &token);
    if (token.type == TOKEN_NONE)
        return Qnil;

    return rb_str_new(token.str, token.length);
}

void init_liquid_tokenizer()
{
    cLiquidTokenizer = rb_define_class_under(mLiquid, "Tokenizer", rb_cObject);
    rb_define_alloc_func(cLiquidTokenizer, rb_allocate);
    rb_define_method(cLiquidTokenizer, "initialize", rb_initialize, 1);
    rb_define_method(cLiquidTokenizer, "next", rb_next, 0);
    rb_define_alias(cLiquidTokenizer, "shift", "next");
}
