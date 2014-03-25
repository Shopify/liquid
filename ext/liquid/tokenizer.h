#ifndef LIQUID_TOKENIZER_H
#define LIQUID_TOKENIZER_H

enum token_type {
    TOKEN_NONE,
    TOKEN_INVALID,
    TOKEN_STRING,
    TOKEN_TAG,
    TOKEN_VARIABLE
};

typedef struct token {
    enum token_type type;
    char *str;
    long length;
} token_t;

typedef struct tokenizer {
    VALUE source;
    char *cursor;
    long length;
} tokenizer_t;

extern VALUE cLiquidTokenizer;
extern const rb_data_type_t tokenizer_data_type;
#define Tokenizer_Get_Struct(obj, sval) TypedData_Get_Struct(obj, tokenizer_t, &tokenizer_data_type, sval)

void init_liquid_tokenizer();
void tokenizer_next(tokenizer_t *tokenizer, token_t *token);

#endif
