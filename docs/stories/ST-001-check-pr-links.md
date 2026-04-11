# ST-001: Implement check-pr-links.sh

## Linked Hypothesis

- HYP-001: A CI gate on PR traceability will prevent chain bypass

## Goal

A shell script that reads a PR body and fails if it contains no `ST-*` reference, so that CI can enforce the minimum traceability requirement.

## Acceptance Criteria

- [ ] Given a PR body containing `ST-001`, the script exits 0
- [ ] Given a PR body with no `ST-*` pattern, the script exits non-zero with a clear error message
- [ ] Given a PR body marked `[fast-lane]`, the script exits 0 without requiring a ST-\* link
- [ ] The script reads PR body from an environment variable (`PR_BODY`) so it can be driven by CI without filesystem dependencies

## Test Level

Integration: run the script against canned `PR_BODY` values in a shell test (e.g. `bats` or plain bash assertions). A unit test cannot validate the regex and exit code behavior together; a full E2E GitHub Actions run is unnecessary overhead for this claim.

## Scope Boundary

**In scope:**

- The shell script itself (`scripts/check-pr-links.sh`)
- Fast-lane exemption via `[fast-lane]` marker in PR body
- Exit codes and stderr output suitable for CI

**Out of scope:**

- Checking that the referenced ST-\* file actually exists (that is ST-002)
- GitHub Actions workflow wiring (that is Phase 3 integration work)
- Checking HYP-\* links inside the ST file (that is ST-002)

## Evidence

- EVID-001: _(link after delivery)_
