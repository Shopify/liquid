# Autoresearch: Liquid Parse+Render Performance

## Objective
Optimize the Shopify Liquid template engine's parse and render performance.
The workload is the ThemeRunner benchmark which parses and renders real Shopify
theme templates (dropify, ripen, tribble, vogue) with realistic data from
`performance/shopify/database.rb`. We measure parse time, render time, and
object allocations. The optimization target is combined parse+render time (µs).

## How to Run
Run `./auto/autoresearch.sh` — it runs unit tests, liquid-spec conformance,
then the performance benchmark, outputting metrics in parseable format.

## Metrics
- **Primary (optimization target)**: `combined_µs` (µs, lower is better) — sum of parse + render time
- **Secondary (tradeoff monitoring)**:
  - `parse_µs` — time to parse all theme templates (Liquid::Template#parse)
  - `render_µs` — time to render all pre-compiled templates
  - `allocations` — total object allocations for one parse+render cycle
  Parse dominates (~70-75% of combined). Allocations correlate with GC pressure.

## Files in Scope
- `lib/liquid/*.rb` — core Liquid library (parser, lexer, context, expression, etc.)
- `lib/liquid/tags/*.rb` — tag implementations (for, if, assign, etc.)
- `performance/bench_quick.rb` — benchmark script

## Off Limits
- `test/` — tests must continue to pass unchanged
- `performance/tests/` — benchmark templates, do not modify
- `performance/shopify/` — benchmark data/filters, do not modify

## Constraints
- All unit tests must pass (`bundle exec rake base_test`)
- liquid-spec failures must not increase beyond 2 (pre-existing UTF-8 edge cases)
- No new gem dependencies
- Semantic correctness must be preserved — templates must render identical output

## Baseline
- **Commit**: 4ea835a (original, before any optimizations)
- **combined_µs**: 7,374
- **parse_µs**: 5,928
- **render_µs**: 1,446
- **allocations**: 62,620

## Progress Log
- 3329b09: Replace FullToken regex with manual byte parsing → combined 7,262 (-1.5%)
- 97e6893: Replace VariableParser regex with manual byte scanner → combined 6,945 (-5.8%), allocs 58,009
- 2b78e4b: getbyte instead of string indexing in whitespace_handler/create_variable → allocs 51,477
- d291e63: Lexer equal? for frozen arrays, \s+ whitespace skip → combined ~6,331
- d79b9fa: Avoid strip alloc in Expression.parse, byteslice for strings → allocs 49,151
- fa41224: Short-circuit parse_number with first-byte check → allocs 48,240
- c1113ad: Fast-path String in render_obj_to_output → combined ~6,071
- 25f9224: Fast-path simple variable parsing (skip Lexer/Parser) → combined ~5,860, allocs 45,202
- 3939d74: Replace SIMPLE_VARIABLE regex with byte scanner → combined ~5,717, allocs 42,763
- fe7a2f5: Fast-path simple if conditions → combined ~5,444, allocs 41,490
- cfa0dfe: Replace For tag Syntax regex with manual byte parser → combined ~4,974, allocs 39,847
- 8a92a4e: Unified fast-path Variable: parse name directly, only lex filter chain → combined ~5,060, allocs 40,520
- 58d2514: parse_tag_token returns [tag_name, markup, newlines] → combined ~4,815, allocs 37,355
- db43492: Hoist write score check out of render loop → render ~1,345
- 17daac9: Extend fast-path to quoted string literal variables → all 1,197 variables fast-pathed
