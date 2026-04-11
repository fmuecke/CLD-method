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

Before writing any code, answer: _"What assumption does this code test?"_
If you cannot answer, stop and return to discovery.

No step can be bypassed without explicit justification. The chain is the constraint.

## Artifact Types

| Prefix | Type           | Location            | Purpose                                            |
| ------ | -------------- | ------------------- | -------------------------------------------------- |
| INIT   | Initiative     | `docs/initiatives/` | Describe the pain, not a solution                  |
| HYP    | Hypothesis     | `docs/hypotheses/`  | Falsifiable assumption with smallest possible test |
| ST     | Story          | `docs/stories/`     | Bounded slice — expected behavior IS the test spec |
| IMPL   | Implementation | PR / commit         | Code change — must reference a ST-\*               |
| EVID   | Evidence       | `docs/evidence/`    | Expected vs actual — must end with a decision      |

Templates: `docs/cld/templates/`

## Falsification-First

Every hypothesis must define what would disprove it — not just what would confirm it.

- **Falsification signal:** what specific result would make this hypothesis unlikely or wrong?
- **Why a positive result is not trivial:** what would a skeptic say about a confirming result?
- **Alternative hypothesis:** what else could explain the same problem? Must be a real competitor, not a strawman.
- **Time to evidence:** how quickly can we get signal? Prefer a worse test sooner over a perfect test later.

## Smallest Possible Test

Every hypothesis and story must define the cheapest test that confirms or rejects it.
Test level is chosen by what validates the claim — not by convention, not by coverage targets.

- **Hypothesis** → "What would falsify this?" defines the test
- **Story** → expected behavior (Given/When/Then) is the test spec, not a separate artifact
- **Implementation** → write the test that matches the falsification signal, then implement against it
- **Evidence** → test result = expected vs actual = confirmation or rejection
- **Review** → does the test actually falsify the hypothesis if the result is negative?

A well-chosen integration test that proves behavior beats 50 unit tests that prove implementation
details. You are optimizing for **uncertainty reduced per test**, not lines covered.

## Agent Roles

Full role definitions in `docs/cld/agents/`. Summary:

### Discovery

- **Inputs:** Vague request, issue, or problem description
- **Outputs:** INIT-\*.md, HYP-\*.md, alternatives analysis (2–3 options with tradeoffs)
- **Must do:** Challenge every problem statement. For each hypothesis, produce a falsification signal, a genuine alternative hypothesis, and a time-to-evidence target.
- **Must not do:** Write production code. Create ST-\*.md. Deliver implementation suggestions before at least one alternative explanation is formulated.

### Delivery

- **Inputs:** Approved ST-\*.md + linked HYP-\*.md with a named falsification signal
- **Outputs:** Code, tests, EVID-\*.md
- **Must do:** Confirm falsification signal exists before writing code. Write the test that matches it first. Produce EVID-\*.md with expected vs actual.
- **Must not do:** Write code before claim and falsification signal are named. Invent requirements. Merge without a linked ST-\*.

### Review

- **Inputs:** PR with linked ST-\*, HYP-\*, EVID-\*
- **Outputs:** Approval / rejection / conditional approval with specific gaps listed
- **Must do:** Verify the full chain. Check test level matches the claim type. Apply anti-gaming heuristics (strawman alternatives, trivial falsification, hypothesis ≈ implementation). Check hypothesis-evidence type match.
- **Must not do:** Approve a PR without a linked ST-\*. Accept "tests pass" as sufficient evidence.

## Fast-lane

Operational changes where the verification is deterministic don't generate hypotheses — the test suite is already the falsification mechanism. Full CLD applies when there is genuine uncertainty about an assumption. Fast-lane applies when the risk is breakage, not wrong direction.

**Use fast-lane for:** bug fixes with a clear root cause, refactors with no behavior change, dependency updates, config changes.

**Use full CLD for:** anything where a wrong assumption could cause you to build the wrong thing — new behavior, new user-facing flows, architectural choices with competing options.

Fast-lane still requires:

- Expected effect statement
- Test evidence (or explicit justification for why no new test is needed)
- Rollback consideration

Mark PR body with `[fast-lane]` and a one-line justification.

**Example:** `[fast-lane]` Bump X from 1.1 to 1.2 for security patch CVE-XXXX. Expected: CI green, no breaking changes per changelog. Rollback: revert to 1.1.

## Gate Checks (Phase 3)

**Pre-commit** (fast local feedback):

- `scripts/check-pr-links.sh` — commit/PR references at least one ST-\*
- `scripts/check-pr-template.sh` — required sections not empty

**CI** (non-bypassable):

- `scripts/check-story-links.sh` — referenced ST-\* contains a HYP-\* link
- `scripts/check-test-evidence.sh` — PR includes test change or explicit justification

Workflow: `.github/workflows/cld-gate-check.yml`
