# AGENTS.md — Closed-Loop Delivery (CLD)

> Every hypothesis implies its own test. Find the cheapest test that would confirm
> or reject it. Implement against that test. The test result is the evidence.

This file is the single source of truth for CLD behavioral rules. All platform-specific
instruction files (CLAUDE.md, copilot-instructions.md) derive from this.

## What This Repo Does

CLD is a repository-native constraint system that prevents agents and humans from skipping
the uncomfortable parts: stating assumptions, exploring alternatives, and validating before
committing. AI removes execution cost but amplifies the cost of wrong assumptions. CLD embeds
epistemic discipline into the repo structure itself.

## Mandatory Workflow

**Issue → INIT → HYP → ST → IMPL → PR → Review → EVID**

Before writing any code, answer: *"What assumption does this code test?"*
If you cannot answer, stop and return to discovery.

No step can be bypassed without explicit justification. The chain is the constraint.

## Artifact Types

| Prefix | Type | Location | Purpose |
|--------|------|----------|---------|
| INIT | Initiative | `docs/initiatives/` | Describe the pain, not a solution |
| HYP | Hypothesis | `docs/hypotheses/` | Falsifiable assumption with smallest possible test |
| ST | Story | `docs/stories/` | Bounded slice — expected behavior IS the test spec |
| IMPL | Implementation | PR / commit | Code change — must reference a ST-* |
| EVID | Evidence | `docs/evidence/` | Expected vs actual — must end with a decision |

Templates: `docs/cld/templates/`

## Smallest Possible Test

Every hypothesis and story must define the cheapest test that confirms or rejects it.
Test level is chosen by what validates the claim — not by convention, not by coverage targets.

- **Hypothesis** → "What would prove this wrong?" defines the test
- **Story** → expected behavior (Given/When/Then) is the test spec, not a separate artifact
- **Implementation** → write the one test that validates the behavior, then implement against it
- **Evidence** → test result = expected vs actual = confirmation or rejection
- **Review** → does the test actually validate the hypothesis, not whether coverage is high enough

A well-chosen integration test that proves behavior beats 50 unit tests that prove implementation
details. You are optimizing for **uncertainty reduced per test**, not lines covered.

## Agent Roles

Full role definitions in `docs/cld/agents/`. Summary:

### Discovery
- **Inputs:** Vague request, issue, or problem description
- **Outputs:** INIT-*.md, HYP-*.md, alternatives analysis (2–3 options with tradeoffs)
- **Must do:** Challenge every problem statement. Ask "what are we assuming?" For each hypothesis, ask "what is the smallest possible test?"
- **Must not do:** Write production code. Create ST-*.md. Recommend a single solution without exploring alternatives.

### Delivery
- **Inputs:** Approved ST-*.md + linked HYP-*.md
- **Outputs:** Code, tests, EVID-*.md
- **Must do:** Write the smallest possible test first. Implement only what makes it pass. Reference ST-* and HYP-* in the PR description. Produce EVID-*.md with expected vs actual.
- **Must not do:** Invent requirements not in the story. Merge without a linked ST-*.

### Review
- **Inputs:** PR with linked ST-*, HYP-*, EVID-*
- **Outputs:** Approval / rejection / conditional approval with specific gaps listed
- **Must do:** Verify the full chain (HYP → ST → IMPL → EVID). Check that test level matches the claim. Flag assumption laundering and coverage theater.
- **Must not do:** Approve a PR without a linked ST-*. Accept "tests pass" as sufficient evidence without verifying what was tested.

## Fast-lane

Bug fixes, refactors, and dependency updates may skip full discovery. Still required:
- Expected effect statement
- Test evidence (or explicit justification for why no new test is needed)
- Rollback consideration

Mark PR body with `[fast-lane]` and a one-line justification.

## Gate Checks (Phase 3)

**Pre-commit** (fast local feedback):
- `scripts/check-pr-links.sh` — commit/PR references at least one ST-*
- `scripts/check-pr-template.sh` — required sections not empty

**CI** (non-bypassable):
- `scripts/check-story-links.sh` — referenced ST-* contains a HYP-* link
- `scripts/check-test-evidence.sh` — PR includes test change or explicit justification

Workflow: `.github/workflows/cld-gate-check.yml`
