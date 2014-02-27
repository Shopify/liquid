#ifndef LIQUID_TOKENIZER_H
#define LIQUID_TOKENIZER_H

enum token_type {
    TOKEN_NONE,
    TOKEN_INVALID,
    TOKEN_STRING,
    TOKEN_TAG,
    TOKEN_VARIABLE
};

struct token {
    enum token_type type;
    char *str;
    int length;
};

struct liquid_tokenizer {
    char *cursor;
    int length;
};

void init_liquid_tokenizer();
void liquid_tokenizer_next(struct liquid_tokenizer *tokenizer, struct token *token);

#endif
