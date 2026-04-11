#!/usr/bin/env bash
# Soft check (CI): anti-gaming heuristics. Produces warnings, never blocks.
# Review agent or human reviewer acts on these flags.
#
# Usage: PR_BODY="..." REPO_ROOT="." bash scripts/check-anti-gaming.sh

set -uo pipefail

BODY="${PR_BODY:-}"
REPO_ROOT="${REPO_ROOT:-.}"
HYPO_DIR="$REPO_ROOT/docs/hypotheses"
STORIES_DIR="$REPO_ROOT/docs/stories"

# Emit a GitHub Actions warning annotation (falls back to stderr outside Actions)
warn() {
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    echo "::warning::$1"
  else
    echo "WARNING: $1" >&2
  fi
}

if [[ -z "$BODY" ]] || echo "$BODY" | grep -qiF '[fast-lane]'; then
  exit 0
fi

get_section() {
  local file="$1"
  local header="$2"
  awk "/^## ${header}/{found=1; next} found && /^## /{exit} found && NF{print}" "$file"
}

# Collect HYP files from referenced stories
ST_REFS=$(echo "$BODY" | grep -oE 'ST-[0-9][0-9A-Z-]*' | sort -u)
HYP_FILES=""

while IFS= read -r ST; do
  [[ -z "$ST" ]] && continue
  STORY_FILE=$(find "$STORIES_DIR" -name "${ST}*.md" 2>/dev/null | head -1)
  [[ -z "$STORY_FILE" ]] && continue
  HYPS=$(grep -oE 'HYP-[0-9][0-9A-Z-]*' "$STORY_FILE" | sort -u)
  while IFS= read -r HYP; do
    [[ -z "$HYP" ]] && continue
    HF=$(find "$HYPO_DIR" -name "${HYP}*.md" 2>/dev/null | head -1)
    [[ -n "$HF" ]] && HYP_FILES="$HYP_FILES $HF"
  done <<< "$HYPS"
done <<< "$ST_REFS"

WARNINGS=0

for HYP_FILE in $HYP_FILES; do
  HYP_NAME=$(basename "$HYP_FILE" .md)

  # 1. Alternative hypothesis too short (likely strawman)
  ALT=$(get_section "$HYP_FILE" "Alternative Hypothesis")
  ALT_LEN=${#ALT}
  if [[ $ALT_LEN -lt 50 ]]; then
    warn "$HYP_NAME: Alternative hypothesis is very short (${ALT_LEN} chars). May be a strawman — verify it is a genuine competing explanation."
    WARNINGS=$((WARNINGS + 1))
  fi

  # 2. Trivial falsification signal
  FALSIFICATION=$(get_section "$HYP_FILE" "Falsification Signal")
  if echo "$FALSIFICATION" | grep -qiE "it doesn.t work|tests fail|doesn.t work|doesn.t pass|fails?$|won.t work"; then
    warn "$HYP_NAME: Falsification signal appears generic. A real falsification signal names a specific observable outcome."
    WARNINGS=$((WARNINGS + 1))
  fi

  # 3. Hypothesis phrasing ≈ implementation (crude heuristic: belief section is very short)
  BELIEF=$(get_section "$HYP_FILE" "Belief")
  BELIEF_LEN=${#BELIEF}
  if [[ $BELIEF_LEN -lt 30 ]]; then
    warn "$HYP_NAME: Belief statement is very short (${BELIEF_LEN} chars). Ensure it is a concrete, falsifiable claim — not a task description."
    WARNINGS=$((WARNINGS + 1))
  fi

done

if [[ $WARNINGS -eq 0 ]]; then
  echo "OK: No anti-gaming flags raised."
else
  echo "Anti-gaming: $WARNINGS warning(s) raised — review before merging."
fi

# Always exit 0 — soft check only
exit 0
