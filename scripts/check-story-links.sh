#!/usr/bin/env bash
# Hard gate (CI only): every ST-* referenced in the PR must link to a HYP-*.
# Requires repo checkout — cannot run as a pre-commit hook.
#
# Usage: PR_BODY="..." REPO_ROOT="." bash scripts/check-story-links.sh

set -euo pipefail

BODY="${PR_BODY:-}"
REPO_ROOT="${REPO_ROOT:-.}"
STORIES_DIR="$REPO_ROOT/docs/stories"

if [[ -z "$BODY" ]]; then
  echo "ERROR: PR_BODY is not set." >&2
  exit 1
fi

if echo "$BODY" | grep -qiF '[fast-lane]'; then
  echo "OK: Fast-lane PR — story link check skipped."
  exit 0
fi

# Extract all ST-* references from the PR body
ST_REFS=$(echo "$BODY" | grep -oE 'ST-[0-9][0-9A-Z-]*' | sort -u)

if [[ -z "$ST_REFS" ]]; then
  echo "ERROR: No ST-* references found in PR body. Run check-pr-links.sh first." >&2
  exit 1
fi

FAILED=0

while IFS= read -r ST; do
  STORY_FILE=$(find "$STORIES_DIR" -name "${ST}*.md" 2>/dev/null | head -1)

  if [[ -z "$STORY_FILE" ]]; then
    echo "FAIL: Story file for $ST not found in $STORIES_DIR/" >&2
    FAILED=1
    continue
  fi

  if grep -qE 'HYP-[0-9]' "$STORY_FILE"; then
    echo "OK: $ST → $(basename "$STORY_FILE") contains a HYP-* link."
  else
    echo "FAIL: $ST ($(basename "$STORY_FILE")) does not contain a HYP-* link." >&2
    echo "  Every story must trace back to a hypothesis." >&2
    FAILED=1
  fi
done <<< "$ST_REFS"

exit $FAILED
