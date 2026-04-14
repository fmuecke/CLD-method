#!/usr/bin/env bash
# Hard gate (CI only): delivery stories (marked '- [x] **Delivery**') require
# the discovery exit contract to be met on the linked HYP-*:
#   - at least one uncertainty has status 'Reduced'
#   - at least one EVID-* is referenced anywhere in the HYP file
#
# Probe stories ('- [x] **Probe**') and fast-lane PRs are skipped.
# The full exit contract checklist lives in cld-discovery/SKILL.md.
#
# Usage: PR_BODY="..." REPO_ROOT="." bash scripts/check-discovery-exit.sh

set -euo pipefail

BODY="${PR_BODY:-}"
REPO_ROOT="${REPO_ROOT:-.}"
STORIES_DIR="$REPO_ROOT/docs/stories"
HYPO_DIR="$REPO_ROOT/docs/hypotheses"

if [[ -z "$BODY" ]]; then
  echo "ERROR: PR_BODY is not set." >&2
  exit 1
fi

if [[ "${BODY,,}" == *'[fast-lane]'* ]]; then
  echo "OK: Fast-lane PR — discovery exit check skipped."
  exit 0
fi

# Get all lines between ## Header and the next ##
get_section() {
  local file="$1"
  local header="$2"
  awk "/^## ${header}/{found=1; next} found && /^## /{exit} found{print}" "$file"
}

# Exit 0 if the story file is marked as a delivery story, 1 otherwise
is_delivery_story() {
  grep -qE '^\- \[x\] \*\*Delivery\*\*' "$1" 2>/dev/null
}

ST_REFS=$(grep -oE 'ST-[0-9][0-9A-Z-]*' <<< "$BODY" | sort -u || true)

if [[ -z "$ST_REFS" ]]; then
  echo "ERROR: No ST-* references found in PR body." >&2
  exit 1
fi

FAILED=0
DELIVERY_COUNT=0

while IFS= read -r ST; do
  [[ -z "$ST" ]] && continue

  STORY_FILE=$(find "$STORIES_DIR" -name "${ST}*.md" 2>/dev/null | head -1)
  if [[ -z "$STORY_FILE" ]]; then
    # check-story-links.sh handles missing story files
    continue
  fi

  if ! is_delivery_story "$STORY_FILE"; then
    echo "OK: $ST is not a delivery story — exit contract check skipped."
    continue
  fi

  DELIVERY_COUNT=$((DELIVERY_COUNT + 1))
  echo "Checking discovery exit contract for $ST (delivery)..."

  # Resolve linked HYP
  HYP_REF=$(grep -oE 'HYP-[0-9][0-9A-Z-]*' "$STORY_FILE" | head -1 || true)
  if [[ -z "$HYP_REF" ]]; then
    echo "FAIL: $ST (delivery) has no HYP-* link." >&2
    FAILED=1
    continue
  fi

  HYP_FILE=$(find "$HYPO_DIR" -name "${HYP_REF}*.md" 2>/dev/null | head -1)
  if [[ -z "$HYP_FILE" ]]; then
    echo "FAIL: Hypothesis file for $HYP_REF not found." >&2
    FAILED=1
    continue
  fi

  # Check 1: at least one uncertainty has status Reduced
  UNC_SECTION=$(get_section "$HYP_FILE" "Uncertainties")
  REDUCED=$(grep -E '\|\s*Reduced\s*\|' <<< "$UNC_SECTION" | wc -l | tr -d ' ')

  if [[ "$REDUCED" -lt 1 ]]; then
    echo "FAIL: $ST → $HYP_REF has no uncertainty with status 'Reduced'." >&2
    echo "  Run at least one probe, record evidence, and mark an uncertainty Reduced" >&2
    echo "  before beginning delivery." >&2
    echo "  See .agents/skills/cld-discovery/SKILL.md → Discovery Exit Contract." >&2
    FAILED=1
  else
    echo "OK: $ST → $HYP_REF — $REDUCED uncertainty/uncertainties marked Reduced."
  fi

  # Check 2: at least one EVID-* referenced in the HYP file
  EVID_COUNT=$(grep -E 'EVID-[0-9]' "$HYP_FILE" | wc -l | tr -d ' ')

  if [[ "$EVID_COUNT" -lt 1 ]]; then
    echo "FAIL: $ST → $HYP_REF has no EVID-* reference." >&2
    echo "  Link at least one evidence document before beginning delivery." >&2
    FAILED=1
  else
    echo "OK: $ST → $HYP_REF — $EVID_COUNT EVID reference(s) found."
  fi

done <<< "$ST_REFS"

if [[ "$DELIVERY_COUNT" -eq 0 ]]; then
  echo "OK: No delivery stories found — discovery exit check not applicable."
fi

exit $FAILED
