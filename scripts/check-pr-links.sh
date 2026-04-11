#!/usr/bin/env bash
# Hard gate: PR body must reference at least one ST-* artifact.
# Fast-lane PRs are exempt if marked with [fast-lane].
#
# Usage (CI):        PR_BODY="${{ github.event.pull_request.body }}" bash scripts/check-pr-links.sh
# Usage (pre-commit): bash scripts/check-pr-links.sh "$(cat $1)"  # $1 = commit message file

set -euo pipefail

BODY="${PR_BODY:-${1:-}}"

if [[ -z "$BODY" ]]; then
  echo "ERROR: No PR body provided. Set PR_BODY or pass commit message as argument." >&2
  exit 1
fi

if echo "$BODY" | grep -qiF '[fast-lane]'; then
  echo "OK: Fast-lane PR — ST-* check skipped."
  exit 0
fi

if echo "$BODY" | grep -qE 'ST-[0-9]'; then
  echo "OK: PR references a ST-* artifact."
  exit 0
fi

echo "FAIL: PR body must reference at least one ST-* artifact." >&2
echo "  Add 'ST-YYYY-NNN' to your PR description, or mark as '[fast-lane]' with a justification." >&2
exit 1
