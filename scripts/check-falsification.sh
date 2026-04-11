#!/usr/bin/env bash
# Hard gate (CI only): every HYP-* linked from referenced stories must have
# a non-empty Falsification Signal and Alternative Hypothesis section.
#
# Usage: PR_BODY="..." REPO_ROOT="." bash scripts/check-falsification.sh

set -euo pipefail

BODY="${PR_BODY:-}"
REPO_ROOT="${REPO_ROOT:-.}"
STORIES_DIR="$REPO_ROOT/docs/stories"
HYPO_DIR="$REPO_ROOT/docs/hypotheses"

if [[ -z "$BODY" ]]; then
  echo "ERROR: PR_BODY is not set." >&2
  exit 1
fi

if echo "$BODY" | grep -qiF '[fast-lane]'; then
  echo "OK: Fast-lane PR — falsification check skipped."
  exit 0
fi

# Get content of a markdown section (text between ## Header and the next ##)
get_section() {
  local file="$1"
  local header="$2"
  awk "/^## ${header}/{found=1; next} found && /^## /{exit} found && NF{print}" "$file"
}

# Collect HYP-* IDs from all referenced story files
ST_REFS=$(echo "$BODY" | grep -oE 'ST-[0-9][0-9A-Z-]*' | sort -u)
HYP_REFS=""

while IFS= read -r ST; do
  STORY_FILE=$(find "$STORIES_DIR" -name "${ST}*.md" 2>/dev/null | head -1)
  [[ -z "$STORY_FILE" ]] && continue
  HYPS=$(grep -oE 'HYP-[0-9][0-9A-Z-]*' "$STORY_FILE" | sort -u)
  HYP_REFS="$HYP_REFS"$'\n'"$HYPS"
done <<< "$ST_REFS"

HYP_REFS=$(echo "$HYP_REFS" | grep -v '^$' | sort -u)

if [[ -z "$HYP_REFS" ]]; then
  echo "ERROR: No HYP-* references found in referenced stories." >&2
  exit 1
fi

FAILED=0

while IFS= read -r HYP; do
  HYP_FILE=$(find "$HYPO_DIR" -name "${HYP}*.md" 2>/dev/null | head -1)

  if [[ -z "$HYP_FILE" ]]; then
    echo "FAIL: Hypothesis file for $HYP not found in $HYPO_DIR/" >&2
    FAILED=1
    continue
  fi

  # Check Falsification Signal
  FALSIFICATION=$(get_section "$HYP_FILE" "Falsification Signal")
  if [[ -z "$FALSIFICATION" ]]; then
    echo "FAIL: $HYP is missing a Falsification Signal." >&2
    echo "  Add a '## Falsification Signal' section with a specific, observable result." >&2
    FAILED=1
  else
    echo "OK: $HYP has a Falsification Signal."
  fi

  # Check Alternative Hypothesis
  ALTERNATIVE=$(get_section "$HYP_FILE" "Alternative Hypothesis")
  if [[ -z "$ALTERNATIVE" ]]; then
    echo "FAIL: $HYP is missing an Alternative Hypothesis." >&2
    echo "  Add a '## Alternative Hypothesis' section with a genuine competing explanation." >&2
    FAILED=1
  else
    echo "OK: $HYP has an Alternative Hypothesis."
  fi

done <<< "$HYP_REFS"

exit $FAILED
