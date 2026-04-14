# CLD Gate Check Scripts

These scripts are the enforcement layer for the CLD workflow. CI runs them on every
PR via `.github/workflows/cld-gate-check.yml`. You can run them locally before pushing.

## Running locally (Windows — Git Bash)

The scripts require `PR_BODY` and `REPO_ROOT`. Run from the repo root in Git Bash
(not PowerShell or CMD).

```bash
export PR_BODY="Implements ST-2024-001 — adds feature X"
export REPO_ROOT="."
export BASE_BRANCH="main"

# Hard gates — mirror the CI job, stop on first failure
bash scripts/check-pr-links.sh        && \
bash scripts/check-pr-template.sh     && \
bash scripts/check-story-links.sh     && \
bash scripts/check-falsification.sh   && \
bash scripts/check-uncertainties.sh   && \
bash scripts/check-discovery-exit.sh  && \
bash scripts/check-test-evidence.sh   && \
echo "All hard gates passed."

# Soft checks — warnings only, never block
bash scripts/check-anti-gaming.sh
```

For a `[fast-lane]` PR, most checks short-circuit automatically:

```bash
export PR_BODY="[fast-lane] bump lodash 4.17.20 → 4.17.21, CVE-2021-23337"
export REPO_ROOT="."
```

## Known local gap

`check-test-evidence.sh` uses `git diff --name-only origin/${BASE_BRANCH}...HEAD`
to find changed files. If `origin/main` is not available (offline, shallow clone),
it falls back to `HEAD~1`. This is usually fine for local testing.

## Pre-commit hooks

To install the pre-commit hook (checks commit messages locally):

```bash
bash scripts/install-hooks.sh
```

This installs `.git/hooks/commit-msg`, which runs `check-pr-links.sh` on every
commit. CI runs the full suite regardless — `git commit --no-verify` bypasses
hooks but not CI.

## Script reference

| Script                     | Gate type | When it runs          | What it checks                                                              |
| -------------------------- | --------- | --------------------- | --------------------------------------------------------------------------- |
| `check-pr-links.sh`        | Hard      | All PRs               | PR body references at least one `ST-*`                                      |
| `check-pr-template.sh`     | Hard      | All PRs               | Required PR template sections are not empty                                 |
| `check-story-links.sh`     | Hard      | Non-fast-lane         | Referenced `ST-*` files contain a `HYP-*` link                              |
| `check-falsification.sh`   | Hard      | Non-fast-lane         | Linked `HYP-*` has a Falsification Signal and Alternative Hypothesis        |
| `check-uncertainties.sh`   | Hard      | Non-fast-lane         | Linked `HYP-*` has ≥2 `UNC-*` rows and a Selected Uncertainty              |
| `check-discovery-exit.sh`  | Hard      | Delivery stories only | Linked `HYP-*` has ≥1 uncertainty Reduced and at least one `EVID-*` link   |
| `check-test-evidence.sh`   | Hard      | Non-fast-lane         | PR includes a test file change, or explicit `[no-test]` justification       |
| `check-anti-gaming.sh`     | Soft      | All PRs               | Heuristic flags: strawman alternatives, trivial falsification, broad claims |
