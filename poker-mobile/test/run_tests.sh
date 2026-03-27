#!/usr/bin/env bash
# Poker Sharp — Test Runner Script
# Runs all tests, captures output, and generates a summary.
#
# Usage:
#   bash test/run_tests.sh
#   bash test/run_tests.sh test/core/poker_test.dart   # run specific file

set -euo pipefail

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Create results directory
RESULTS_DIR="test/results"
mkdir -p "$RESULTS_DIR"

# Timestamp for output file
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="$RESULTS_DIR/test_output_${TIMESTAMP}.txt"

echo "╔═══════════════════════════════════════════════╗"
echo "║  Poker Sharp — Test Runner                    ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "Timestamp: $(date)"
echo "Output:    $OUTPUT_FILE"
echo ""

# Determine what to test
TEST_TARGET="${1:-}"

# Run tests and capture output
EXIT_CODE=0
if [ -n "$TEST_TARGET" ]; then
    echo "Running: flutter test --reporter=expanded $TEST_TARGET"
    echo ""
    flutter test --reporter=expanded "$TEST_TARGET" 2>&1 | tee "$OUTPUT_FILE" || EXIT_CODE=$?
else
    echo "Running: flutter test --reporter=expanded"
    echo ""
    flutter test --reporter=expanded 2>&1 | tee "$OUTPUT_FILE" || EXIT_CODE=$?
fi

echo ""
echo "═══════════════════════════════════════════════"
echo ""

# Parse summary from output
TOTAL=$(grep -cE '^\s*(✓|✗|~)' "$OUTPUT_FILE" 2>/dev/null || echo "0")
PASSED=$(grep -cE '^\s*✓' "$OUTPUT_FILE" 2>/dev/null || echo "0")
FAILED=$(grep -cE '^\s*✗' "$OUTPUT_FILE" 2>/dev/null || echo "0")
SKIPPED=$(grep -cE '^\s*~' "$OUTPUT_FILE" 2>/dev/null || echo "0")

# Fallback: try numeric summary line from Flutter
if [ "$TOTAL" = "0" ]; then
    SUMMARY_LINE=$(grep -oE '[0-9]+ tests? passed' "$OUTPUT_FILE" 2>/dev/null || echo "")
    if [ -n "$SUMMARY_LINE" ]; then
        PASSED=$(echo "$SUMMARY_LINE" | grep -oE '^[0-9]+')
    fi
    FAIL_LINE=$(grep -oE '[0-9]+ tests? failed' "$OUTPUT_FILE" 2>/dev/null || echo "")
    if [ -n "$FAIL_LINE" ]; then
        FAILED=$(echo "$FAIL_LINE" | grep -oE '^[0-9]+')
    fi
    TOTAL=$((PASSED + FAILED + SKIPPED))
fi

# Print summary
echo "SUMMARY"
echo "-------"
echo "  Total:   $TOTAL"
echo "  Passed:  $PASSED"
echo "  Failed:  $FAILED"
echo "  Skipped: $SKIPPED"
echo ""

if [ "$EXIT_CODE" -ne 0 ]; then
    echo "❌ TESTS FAILED (exit code: $EXIT_CODE)"
    echo ""
    echo "Failed tests:"
    grep -E '^\s*✗' "$OUTPUT_FILE" 2>/dev/null || echo "  (see $OUTPUT_FILE for details)"
    echo ""
    echo "To debug a specific failing test:"
    echo "  flutter test --reporter=expanded --name='<test name>' <test file>"
    echo ""
    echo "To dump app_logger output for diagnostics:"
    echo "  See AppLogger.enableTestMode() / AppLogger.dumpCapturedLogs()"
else
    echo "✅ ALL TESTS PASSED"
fi

echo ""
echo "Full output saved to: $OUTPUT_FILE"
echo ""

# Append summary to the output file
{
    echo ""
    echo "═══════════════════════════════════════════════"
    echo "SUMMARY"
    echo "  Total:   $TOTAL"
    echo "  Passed:  $PASSED"
    echo "  Failed:  $FAILED"
    echo "  Skipped: $SKIPPED"
    echo "  Exit:    $EXIT_CODE"
} >> "$OUTPUT_FILE"

exit "$EXIT_CODE"
