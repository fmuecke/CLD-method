#!/usr/bin/env bash
# Installs CLD pre-commit hooks into .git/hooks/.
# Run once after cloning: bash scripts/install-hooks.sh

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

if [[ ! -d "$HOOKS_DIR" ]]; then
  echo "ERROR: Not inside a git repository or .git/hooks/ not found." >&2
  exit 1
fi

# commit-msg hook: check that commit message references a ST-* artifact (or is fast-lane)
cat > "$HOOKS_DIR/commit-msg" << 'EOF'
#!/usr/bin/env bash
# CLD: commit message must reference ST-* or be marked [fast-lane]
COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")
export PR_BODY="$COMMIT_MSG"
exec bash "$(git rev-parse --show-toplevel)/scripts/check-pr-links.sh"
EOF

chmod +x "$HOOKS_DIR/commit-msg"
echo "Installed: .git/hooks/commit-msg (check-pr-links)"

echo ""
echo "Done. Pre-commit hooks active."
echo "To bypass in an emergency: git commit --no-verify (CI will still catch it)"
