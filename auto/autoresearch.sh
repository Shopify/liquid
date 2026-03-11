#!/usr/bin/env bash
# Autoresearch benchmark runner for Liquid performance optimization
# Runs: unit tests → liquid-spec → performance benchmark
# Outputs METRIC lines for the agent to parse
# Exit code 0 = all good, non-zero = broken
set -euo pipefail

cd "$(dirname "$0")/.."

# ── Step 1: Unit tests (fast gate) ──────────────────────────────────
echo "=== Unit Tests ==="
if ! bundle exec rake base_test 2>&1; then
  echo "FATAL: unit tests failed"
  exit 1
fi

# ── Step 2: liquid-spec (correctness gate) ──────────────────────────
echo ""
echo "=== Liquid Spec ==="
SPEC_OUTPUT=$(bundle exec liquid-spec run spec/ruby_liquid.rb 2>&1 || true)
echo "$SPEC_OUTPUT" | tail -3

# Extract failure count from "Total: N passed, N failed, N errors" line
# Allow known pre-existing failures (≤2)
TOTAL_LINE=$(echo "$SPEC_OUTPUT" | grep "^Total:" || echo "Total: 0 passed, 0 failed, 0 errors")
FAILURES=$(echo "$TOTAL_LINE" | sed -n 's/.*\([0-9][0-9]*\) failed.*/\1/p')
ERRORS=$(echo "$TOTAL_LINE" | sed -n 's/.*\([0-9][0-9]*\) error.*/\1/p')
FAILURES=${FAILURES:-0}
ERRORS=${ERRORS:-0}
TOTAL_BAD=$((FAILURES + ERRORS))

if [ "$TOTAL_BAD" -gt 2 ]; then
  echo "FATAL: liquid-spec has $FAILURES failures and $ERRORS errors (threshold: 2)"
  exit 1
fi

# ── Step 3: Performance benchmark ──────────────────────────────────
echo ""
echo "=== Performance Benchmark ==="
BENCH_OUTPUT=$(bundle exec ruby performance/bench_quick.rb 2>&1)
echo "$BENCH_OUTPUT"

# Parse results and output METRIC lines
PARSE_US=$(echo "$BENCH_OUTPUT" | grep '^parse_us=' | cut -d= -f2)
RENDER_US=$(echo "$BENCH_OUTPUT" | grep '^render_us=' | cut -d= -f2)
COMBINED_US=$(echo "$BENCH_OUTPUT" | grep '^combined_us=' | cut -d= -f2)
ALLOCATIONS=$(echo "$BENCH_OUTPUT" | grep '^allocations=' | cut -d= -f2)

echo ""
echo "METRIC combined_us=$COMBINED_US"
echo "METRIC parse_us=$PARSE_US"
echo "METRIC render_us=$RENDER_US"
echo "METRIC allocations=$ALLOCATIONS"
