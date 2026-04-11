#!/usr/bin/env bash
# Hard gate: required PR template sections must not be empty or left as placeholders.
# Detects track (Full CLD vs fast-lane) from PR body and validates accordingly.
#
# Usage: PR_BODY="${{ github.event.pull_request.body }}" bash scripts/check-pr-template.sh

set -euo pipefail

BODY="${PR_BODY:-}"

if [[ -z "$BODY" ]]; then
  echo "ERROR: PR_BODY is not set." >&2
  exit 1
fi

is_fast_lane() {
  echo "$BODY" | grep -qiF '[fast-lane]'
}

# Check that a line following a pattern has non-empty, non-placeholder content.
# Args: label, search pattern
check_field() {
  local label="$1"
  local pattern="$2"
  local value
  value=$(echo "$BODY" | grep -A1 "$pattern" | tail -1 | sed 's/^[[:space:]]*//')
  if [[ -z "$value" || "$value" == "_"* || "$value" == "<!--"* ]]; then
    echo "FAIL: '$label' is empty or not filled in." >&2
    return 1
  fi
  return 0
}

FAILED=0

if is_fast_lane; then
  echo "Fast-lane track detected."
  check_field "Expected effect"    "Expected effect:"    || FAILED=1
  check_field "Test evidence"      "Test evidence:"      || FAILED=1
  check_field "Rollback"           "Rollback:"           || FAILED=1
else
  echo "Full CLD track detected."
  check_field "What assumption is being acted on"  "What assumption is being acted on"  || FAILED=1
  check_field "What would falsify it"              "What would falsify it"              || FAILED=1
  check_field "What remains uncertain"             "What remains uncertain"             || FAILED=1
  check_field "What are we choosing to believe"    "What are we choosing to believe"    || FAILED=1
  check_field "Reversal trigger"                   "Reversal trigger:"                  || FAILED=1
fi

if [[ $FAILED -eq 0 ]]; then
  echo "OK: All required PR template sections are filled in."
fi

exit $FAILED
