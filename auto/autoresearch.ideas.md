# Autoresearch Ideas

## Dead Ends (tried and failed)

- **Tag name interning** (skip+byte dispatch): saves 878 allocs but verification loop overhead kills speed
- **String dedup (-@)** for filter names: no alloc savings, creates temp strings anyway
- **Split-based tokenizer**: 2.5x faster C-level split but can't handle {{ followed by %} nesting
- **Streaming tokenizer**: needs own StringScanner (+alloc), per-shift overhead worse than eager array
- **Merge simple_lookup? into initialize**: logic overhead offsets saved index call
- **Cursor for filter scanning**: cursor.reset overhead worse than inline byte loops
- **Direct strainer call**: YJIT already inlines context.invoke_single well
- **TruthyCondition subclass**: YJIT polymorphism at evaluate call site hurts more than 115 saved allocs
- **Index loop for filters**: YJIT optimizes each+destructure MUCH better than manual filter[0]/filter[1]

## Key Insights

- YJIT monomorphism > allocation reduction at this scale
- C-level StringScanner.scan/skip > Ruby-level byte loops (already applied)
- String#split is 2.5x faster than manual tokenization, but Liquid's grammar is too complex for regex
- 74% of total CPU time is GC — alloc reduction is the highest-leverage optimization
- But YJIT-deoptimization from polymorphism costs more than the GC savings

## Remaining Ideas

- **Tokenizer: use String#index + byteslice instead of StringScanner**: avoid the StringScanner overhead entirely for the simple case of finding {%/{{ delimiters
- **Pre-freeze all Condition operator lambdas**: reduce alloc in Condition initialization
- **Avoid `@blocks = []` in If with single-element optimization**: use `@block` ivar for single condition, only create array for elsif
- **Reduce ForloopDrop allocation**: reuse ForloopDrop objects across iterations or use a lighter-weight object
- **VariableLookup: single-segment optimization**: for "product.title" (1 lookup), use an ivar instead of 1-element Array

