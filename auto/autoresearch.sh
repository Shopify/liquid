#!/usr/bin/env bash
# Autoresearch benchmark runner for Liquid performance optimization
# Runs: unit tests → performance benchmark (3 runs, takes best)
# Outputs METRIC lines for the agent to parse
# Exit code 0 = all good, non-zero = broken
set -euo pipefail

cd "$(dirname "$0")/.."

# ── Step 1: Unit tests (fast gate) ──────────────────────────────────
echo "=== Unit Tests ==="
TEST_OUT=$(bundle exec rake base_test 2>&1)
TEST_RESULT=$(echo "$TEST_OUT" | tail -1)
if echo "$TEST_OUT" | grep -q 'failures\|errors' && ! echo "$TEST_RESULT" | grep -q '0 failures, 0 errors'; then
  echo "$TEST_OUT" | grep -E 'Failure|Error|failures|errors' | head -20
  echo "FATAL: unit tests failed"
  exit 1
fi
echo "$TEST_RESULT"

# ── Step 2: Performance benchmark (3 runs, take best) ──────────────
echo ""
echo "=== Performance Benchmark (3 runs) ==="
BEST_COMBINED=999999
BEST_PARSE=0
BEST_RENDER=0
BEST_ALLOC=0

for i in 1 2 3; do
  OUT=$(bundle exec ruby performance/bench_quick.rb 2>&1)
  P=$(echo "$OUT" | grep '^parse_us=' | cut -d= -f2)
  R=$(echo "$OUT" | grep '^render_us=' | cut -d= -f2)
  C=$(echo "$OUT" | grep '^combined_us=' | cut -d= -f2)
  A=$(echo "$OUT" | grep '^allocations=' | cut -d= -f2)
  echo "  run $i: combined=${C}µs (parse=${P} render=${R}) allocs=${A}"
  if [ "$C" -lt "$BEST_COMBINED" ]; then
    BEST_COMBINED=$C
    BEST_PARSE=$P
    BEST_RENDER=$R
    BEST_ALLOC=$A
  fi
done

echo ""
echo "METRIC combined_us=$BEST_COMBINED"
echo "METRIC parse_us=$BEST_PARSE"
echo "METRIC render_us=$BEST_RENDER"
echo "METRIC allocations=$BEST_ALLOC"
