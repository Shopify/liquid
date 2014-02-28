#include "liquid_ext.h"

VALUE cLiquidBlock;
ID intern_assert_missing_delimitation, intern_block_delimiter, intern_is_blank,
   intern_new_with_options, intern_tags, intern_unknown_tag, intern_unterminated_tag,
   intern_unterminated_variable;

struct liquid_tag
{
    char *name, *markup;
    long name_length, markup_length;
};

static bool parse_tag(struct liquid_tag *tag, char *token, long token_length)
{
    // Strip {{ and }} braces
    token += 2;
    token_length -= 4;

    char *end = token + token_length;
    while (token < end && isspace(*token))
        token++;
    tag->name = token;

    char c = *token;
    while (token < end && (isalnum(c) || c == '_'))
        c = *(++token);
    tag->name_length = token - tag->name;
    if (!tag->name_length) {
        memset(tag, 0, sizeof(*tag));
        return false;
    }

    while (token < end && isspace(*token))
        token++;
    tag->markup = token;

    char *last = end - 1;
    while (token < last && isspace(*last))
        last--;
    end = last + 1;
    tag->markup_length = end - token;
    return true;
}

static VALUE rb_parse_body(VALUE self, VALUE tokenizerObj)
{
    struct liquid_tokenizer *tokenizer = LIQUID_TOKENIZER_GET_STRUCT(tokenizerObj);

    bool blank = true;
    VALUE nodelist = rb_iv_get(self, "@nodelist");
    if (nodelist == Qnil) {
        nodelist = rb_ary_new();
        rb_iv_set(self, "@nodelist", nodelist);
    } else {
        rb_ary_clear(nodelist);
    }

    struct token token;
    while (true) {
        liquid_tokenizer_next(tokenizer, &token);
        switch (token.type) {
        case TOKEN_NONE:
            /*
             * Make sure that it's ok to end parsing in the current block.
             * Effectively this method will throw an exception unless the current block is
             * of type Document
             */
            rb_funcall(self, intern_assert_missing_delimitation, 0);
            goto done;
        case TOKEN_INVALID:
        {
            VALUE token_obj = rb_str_new(token.str, token.length);
            if (token.str[1] == '%')
                rb_funcall(self, intern_unterminated_tag, 1, token_obj);
            else
                rb_funcall(self, intern_unterminated_variable, 1, token_obj);
            break;
        }
        case TOKEN_TAG:
        {
            struct liquid_tag tag;
            if (!parse_tag(&tag, token.str, token.length)) {
                // FIXME: provide more appropriate error message
                rb_funcall(self, intern_unterminated_tag, 1, rb_str_new(token.str, token.length));
            } else {
                if (tag.name_length >= 3 && !memcmp(tag.name, "end", 3)) {
                    VALUE block_delimiter = rb_funcall(self, intern_block_delimiter, 0);
                    if (TYPE(block_delimiter) == T_STRING &&
                        tag.name_length == RSTRING_LEN(block_delimiter) &&
                        !memcmp(tag.name, RSTRING_PTR(block_delimiter), tag.name_length))
                    {
                        goto done;
                    }
                }

                VALUE tags = rb_funcall(cLiquidTemplate, intern_tags, 0);
                Check_Type(tags, T_HASH);
                VALUE tag_name = rb_str_new(tag.name, tag.name_length);
                VALUE tag_class = rb_hash_lookup(tags, tag_name);
                VALUE markup = rb_str_new(tag.markup, tag.markup_length);
                if (tag_class != Qnil) {
                    VALUE options = rb_iv_get(self, "@options");
                    if (options == Qnil)
                        options = rb_hash_new();
                    VALUE new_tag = rb_funcall(tag_class, intern_new_with_options, 4,
                                               tag_name, markup, tokenizerObj, options);
                    if (blank) {
                        VALUE blank_block = rb_funcall(new_tag, intern_is_blank, 0);
                        if (blank_block == Qnil || blank_block == Qfalse)
                            blank = false;
                    }
                    rb_ary_push(nodelist, new_tag);
                } else {
                    rb_funcall(self, intern_unknown_tag, 3, tag_name, markup, tokenizerObj);
                    /*
                     * multi-block tags may store the nodelist in a block array on unknown_tag
                     * then replace @nodelist with a new array. We need to use the new array
                     * for the block following the tag token.
                     */
                    nodelist = rb_iv_get(self, "@nodelist");
                }
            }
            break;
        }
        case TOKEN_VARIABLE:
        {
            VALUE markup = rb_str_new(token.str + 2, token.length - 4);
            VALUE options = rb_iv_get(self, "@options");
            VALUE new_var = rb_funcall(cLiquidVariable, intern_new, 2, markup, options);
            rb_ary_push(nodelist, new_var);
            blank = false;
            break;
        }
        case TOKEN_STRING:
            rb_ary_push(nodelist, liquid_string_slice_new(token.str, token.length));
            if (blank) {
                int i;
                for (i = 0; i < token.length; i++) {
                    if (!isspace(token.str[i])) {
                        blank = false;
                        break;
                    }
                }
            }
            break;
        }
    }
done:
    rb_iv_set(self, "@blank", blank ? Qtrue : Qfalse);
    return Qnil;
}

void init_liquid_block()
{
    intern_assert_missing_delimitation = rb_intern("assert_missing_delimitation!");
    intern_block_delimiter = rb_intern("block_delimiter");
    intern_is_blank = rb_intern("blank?");
    intern_new_with_options = rb_intern("new_with_options");
    intern_tags = rb_intern("tags");
    intern_unknown_tag = rb_intern("unknown_tag");
    intern_unterminated_tag = rb_intern("unterminated_tag");
    intern_unterminated_variable = rb_intern("unterminated_variable");

    cLiquidBlock = rb_define_class_under(mLiquid, "Block", cLiquidTag);
    rb_define_method(cLiquidBlock, "parse_body", rb_parse_body, 1);
}
