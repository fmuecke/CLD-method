#!/usr/bin/env bash
# Hard gate (CI only): every HYP-* linked from referenced stories must have:
#   - a '## Uncertainties' section with at least 2 rows carrying UNC-* IDs
#   - a '## Selected Uncertainty' section with non-empty content
#
# Status checks (at least one Reduced + EVID link) are handled separately by
# check-discovery-exit.sh, which runs only for delivery stories.
#
# Usage: PR_BODY="..." REPO_ROOT="." bash scripts/check-uncertainties.sh

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
  echo "OK: Fast-lane PR — uncertainty inventory check skipped."
  exit 0
fi

# Get all lines between ## Header and the next ##
get_section() {
  local file="$1"
  local header="$2"
  awk "/^## ${header}/{found=1; next} found && /^## /{exit} found{print}" "$file"
}

# Collect HYP-* IDs from all referenced story files
ST_REFS=$(grep -oE 'ST-[0-9][0-9A-Z-]*' <<< "$BODY" | sort -u || true)
HYP_REFS=""

while IFS= read -r ST; do
  [[ -z "$ST" ]] && continue
  STORY_FILE=$(find "$STORIES_DIR" -name "${ST}*.md" 2>/dev/null | head -1)
  [[ -z "$STORY_FILE" ]] && continue
  HYPS=$(grep -oE 'HYP-[0-9][0-9A-Z-]*' "$STORY_FILE" | sort -u || true)
  HYP_REFS="$HYP_REFS"$'\n'"$HYPS"
done <<< "$ST_REFS"

HYP_REFS=$(grep -v '^$' <<< "$HYP_REFS" | sort -u || true)

if [[ -z "$HYP_REFS" ]]; then
  echo "ERROR: No HYP-* references found in referenced stories." >&2
  exit 1
fi

FAILED=0

while IFS= read -r HYP; do
  [[ -z "$HYP" ]] && continue

  HYP_FILE=$(find "$HYPO_DIR" -name "${HYP}*.md" 2>/dev/null | head -1)
  if [[ -z "$HYP_FILE" ]]; then
    echo "FAIL: Hypothesis file for $HYP not found in $HYPO_DIR/" >&2
    FAILED=1
    continue
  fi

  # --- Check: ## Uncertainties section with ≥2 UNC-* rows ---
  UNC_SECTION=$(get_section "$HYP_FILE" "Uncertainties")

  if [[ -z "$(tr -d '[:space:]' <<< "$UNC_SECTION")" ]]; then
    echo "FAIL: $HYP is missing a '## Uncertainties' section." >&2
    echo "  Add at least 2 unknowns that could each independently invalidate the approach." >&2
    FAILED=1
    continue
  fi

  # Count table rows that carry a UNC-* ID (data rows, not headers or separators)
  DATA_ROWS=$(grep -E '^\| UNC-' <<< "$UNC_SECTION" | wc -l | tr -d ' ')

  if [[ "$DATA_ROWS" -lt 2 ]]; then
    echo "FAIL: $HYP has $DATA_ROWS UNC-* row(s) — need at least 2." >&2
    echo "  Each item must be capable of independently invalidating the approach." >&2
    FAILED=1
  else
    echo "OK: $HYP has $DATA_ROWS uncertainty rows."
  fi

  # --- Check: ## Selected Uncertainty section with content ---
  SELECTED=$(get_section "$HYP_FILE" "Selected Uncertainty")
  # Strip HTML comments and whitespace to detect placeholder-only sections
  SELECTED_CONTENT=$(sed '/^<!--/,/-->/d' <<< "$SELECTED" | tr -d '[:space:]')

  if [[ -z "$SELECTED_CONTENT" ]]; then
    echo "FAIL: $HYP is missing a '## Selected Uncertainty' section with content." >&2
    echo "  Identify which uncertainty this hypothesis targets and why." >&2
    FAILED=1
  else
    echo "OK: $HYP has a Selected Uncertainty."
  fi

done <<< "$HYP_REFS"

exit $FAILED
