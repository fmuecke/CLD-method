#!/usr/bin/env bash
# Hard gate (CI only): PR must include at least one test file change,
# or an explicit justification for why no test is needed.
# Validates presence, not coverage metrics.
#
# Usage: PR_BODY="..." BASE_BRANCH="main" bash scripts/check-test-evidence.sh

set -euo pipefail

BODY="${PR_BODY:-}"
BASE_BRANCH="${BASE_BRANCH:-main}"

if [[ -z "$BODY" ]]; then
  echo "ERROR: PR_BODY is not set." >&2
  exit 1
fi

# Fast-lane: check that "Test evidence:" field is filled
if echo "$BODY" | grep -qiF '[fast-lane]'; then
  EVIDENCE=$(echo "$BODY" | grep -A1 "Test evidence:" | tail -1 | sed 's/^[[:space:]]*//')
  if [[ -z "$EVIDENCE" || "$EVIDENCE" == "_"* ]]; then
    echo "FAIL: Fast-lane PR must fill in the 'Test evidence:' field." >&2
    exit 1
  fi
  echo "OK: Fast-lane test evidence present."
  exit 0
fi

# Check for explicit no-test justification in PR body
if echo "$BODY" | grep -qiE '\[no-test\]|\[no test\]|no new test (needed|required|added)'; then
  echo "OK: Explicit no-test justification found in PR body."
  exit 0
fi

# Get changed files in this PR
CHANGED_FILES=$(git diff --name-only "origin/${BASE_BRANCH}...HEAD" 2>/dev/null \
  || git diff --name-only "HEAD~1" 2>/dev/null \
  || echo "")

if [[ -z "$CHANGED_FILES" ]]; then
  echo "WARNING: Could not determine changed files — skipping test evidence check." >&2
  exit 0
fi

# Check whether any source files changed (to avoid false positives on docs-only PRs)
SOURCE_CHANGES=$(echo "$CHANGED_FILES" | grep -vE '^docs/|^\.github/|^prompts/|^scripts/|\.md$' || true)

if [[ -z "$SOURCE_CHANGES" ]]; then
  echo "OK: No source file changes detected — test check not applicable."
  exit 0
fi

# Check for test file changes
TEST_CHANGES=$(echo "$CHANGED_FILES" | grep -iE '(test|spec)[^/]*\.(sh|js|ts|py|go|rb|rs|java|cs)$|_test\.|\.test\.|\.spec\.' || true)

if [[ -n "$TEST_CHANGES" ]]; then
  echo "OK: Test file changes detected:"
  echo "$TEST_CHANGES" | sed 's/^/  /'
  exit 0
fi

echo "FAIL: Source files changed but no test files found in this PR." >&2
echo "  Either add a test that validates the story behavior, or add '[no-test] <reason>' to the PR body." >&2
exit 1
