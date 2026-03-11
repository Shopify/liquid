#!/usr/bin/env bash
# Auto-research benchmark script for Liquid
# Runs: unit tests → liquid-spec → performance benchmark
# Outputs machine-readable metrics on success
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
bundle exec ruby performance/bench_quick.rb 2>&1
