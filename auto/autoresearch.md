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
- **Security**: Liquid runs untrusted user code. See Strategic Direction for details.

## Strategic Direction
The long-term goal is to converge toward a **single-pass, forward-only parsing
architecture** using one shared StringScanner instance. The current system has
multiple redundant passes: Tokenizer → BlockBody → Lexer → Parser → Expression
→ VariableLookup, each re-scanning portions of the source. A unified scanner
approach would:

1. **One StringScanner** flows through the entire parse — no intermediate token
   arrays, no re-lexing filter chains, no string reconstruction in Parser#expression.
2. **Emit a lightweight IL or normalized AST** during the single forward pass,
   decoupling strictness checking from the hot parse path. The LiquidIL project
   (`~/src/tries/2026-01-05-liquid-il`) demonstrated this: a recursive-descent
   parser emitting IL directly achieved significant speedups.
3. **Minimal backtracking** — the scanner advances forward, byte-checking as it
   goes. liquid-c (`~/src/tries/2026-01-16-Shopify-liquid-c`) showed that a
   C-level cursor-based tokenizer eliminates most allocation overhead.

Current fast-path optimizations (byte-level tag/variable/for/if parsing) are
steps toward this goal. Each one replaces a regex+MatchData pattern with
forward-only byte scanning. The remaining Lexer→Parser path for filter args
is the next target for elimination.

**Security note**: Liquid executes untrusted user templates. All parsing must
use explicit byte-range checks. Never use eval, send on user input, dynamic
method dispatch, const_get, or any pattern that lets template authors escape
the sandbox.

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
- 9fd7cec: Split filter parsing: no-arg filters scanned directly, Lexer only for args → combined ~4,595, allocs 35,159
- e5933fc: Avoid array alloc in parse_tag_token via class ivars → allocs 34,281
- 2e207e6: Replace WhitespaceOrNothing regex with byte-level blank_string? → combined ~4,800
- 526af22: invoke_single fast path for no-arg filter invocation → allocs 32,621
- 76ae8f1: find_variable top-scope fast path → combined ~4,740
- 4cda1a5: slice_collection: skip copy for full Array → allocs 32,004
- 79840b1: Replace SIMPLE_CONDITION regex with manual byte parser → combined ~4,663, allocs 31,465
- 69430e9: Replace INTEGER_REGEX/FLOAT_REGEX with byte-level parse_number → allocs 31,129
- 405e3dc: Frozen EMPTY_ARRAY/EMPTY_HASH for Context @filters/@disabled_tags → allocs 31,009
- b90d7f0: Avoid unnecessary array wrapping for Context environments → allocs 30,709
- 3799d4c: Lazy seen={} hash in Utils.to_s/inspect → allocs 30,169
- 0b07487: Fast-path VariableLookup: skip scan_variable for simple identifiers → allocs 29,711
- 9de1527: Introduce Cursor class for centralized byte-level scanning
- dd4a100: Remove dead parse_tag_token/SIMPLE_CONDITION (now in Cursor)
- cdc3438: For tag: migrate lax_parse to Cursor with zero-alloc scanning → allocs 29,620

## Current Best
- **combined_µs**: ~3,400 (-54% from original 7,374 baseline)
- **parse_µs**: ~2,300
- **render_µs**: ~1,100
- **allocations**: 24,882 (-60% from original 62,620 baseline)
