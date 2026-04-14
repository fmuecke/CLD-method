# AGENTS.md — Closed-Loop Delivery (CLD)

> Before you can state a hypothesis, you must know what you don't know.
> Before you can test a hypothesis, you must target the highest-value uncertainty.
> Every hypothesis implies its own test. Find the cheapest probe that would confirm
> or reject it. The probe result is the evidence.

This file is the single source of truth for CLD behavioral rules. All platform-specific
instruction files (CLAUDE.md, copilot-instructions.md) derive from this.

## What This Repo Does

CLD is a repository-native constraint system that prevents agents and humans from skipping
the uncomfortable parts: stating assumptions, exploring alternatives, and validating before
committing. AI removes execution cost but amplifies the cost of wrong assumptions. CLD embeds
epistemic discipline into the repo structure itself.

## Mandatory Workflow

**Issue → INIT → Uncertainty Inventory → Probe(s) → HYP → ST → IMPL → PR → Review → EVID**

Before writing any code, answer: _"What assumption does this code test?"_
If you cannot answer, stop and return to discovery.

Before writing any hypothesis, answer: _"What don't we know that could kill this?"_
If you cannot list at least 2 uncertainties that could each independently invalidate the idea — ranked by risk × effort — you are not ready to hypothesize. Run the discovery micro-loop first.

No step can be bypassed without explicit justification. The chain is the constraint.

## Artifact Types

| Prefix | Type             | Location            | Purpose                                                    |
| ------ | ---------------- | ------------------- | ---------------------------------------------------------- |
| INIT   | Initiative       | `docs/initiatives/` | Describe the pain, not a solution                          |
| HYP    | Hypothesis       | `docs/hypotheses/`  | Falsifiable assumption with embedded uncertainty inventory |
| ST     | Story (Probe)    | `docs/stories/`     | Evidence-first probe to reduce a specific uncertainty      |
| ST     | Story (Delivery) | `docs/stories/`     | Bounded slice — expected behavior IS the test spec         |
| IMPL   | Implementation   | PR / commit         | Code change — must reference a ST-\*                       |
| EVID   | Evidence         | `docs/evidence/`    | Expected vs actual — must end with a decision + UNC update |

Templates: `docs/cld/templates/`

## Discovery Micro-Loop

Before any hypothesis is created, discovery must run this loop:

1. **Uncertainty inventory** — list at least 2 unknowns that could each independently kill the idea, ranked by risk × effort-to-test. Use stable IDs (e.g. `UNC-ADO-001`).
2. **Select** — pick the uncertainty with the most risk reduced per effort. One at a time.
3. **Probe** — define the cheapest action that gives signal. Must include a concrete sample size. This becomes a probe story (ST-\* with Type: Probe).
4. **Evidence** — execute the probe, record results in EVID-\*, update uncertainty status in HYP-\* (Reduced / Dismissed / Fatal).
5. **Decide** — Fatal result? → abort to INIT. More unknowns? → back to step 2. Enough reduced? → exit to hypothesis.

**Hard rule:** no HYP-\* without at least one uncertainty reduced with evidence.

The discovery exit contract defines the minimum bar for moving from discovery to delivery. See the discovery skill for the full checklist.

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

Full role definitions in `.agents/skills/`. Summary:

### Discovery

- **Inputs:** Vague request, issue, or problem description
- **Outputs:** Uncertainty inventory (ranked), probe stories, INIT-\*.md, HYP-\*.md (with embedded uncertainties), alternatives analysis (2–3 options with tradeoffs)
- **Must do:** Run the discovery micro-loop before any hypothesis. Produce uncertainty inventory (≥2 independently fatal unknowns, ranked). For each hypothesis, produce a falsification signal, a genuine alternative hypothesis, and a time-to-evidence target. Flag anti-patterns (hypothesis too broad, no sample size, probe = production code).
- **Must not do:** Write production code. Create delivery stories. Deliver implementation suggestions before at least one alternative explanation is formulated. Skip the uncertainty inventory. Produce architecture designs or multi-slice plans.

### Delivery

- **Inputs:** Approved ST-\*.md + linked HYP-\*.md with a named falsification signal
- **Outputs:** Code, tests, EVID-\*.md, uncertainty status updates (for probes)
- **Must do:** Check story type (Probe vs Delivery). For probes: execute, record evidence, update uncertainty. For delivery: verify discovery exit contract is met before writing code. Confirm falsification signal exists. Write the test that matches it first. Produce EVID-\*.md with expected vs actual.
- **Must not do:** Write code before claim and falsification signal are named. Start delivery work when the discovery exit contract is not met. Turn probe stories into production code. Invent requirements. Merge without a linked ST-\*.

### Review

- **Inputs:** PR with linked ST-\*, HYP-\*, EVID-\*
- **Outputs:** Approval / rejection / conditional approval with specific gaps listed
- **Must do:** Verify the full chain including uncertainty inventory. Check that at least one uncertainty is "Reduced" with evidence. Check test level matches the claim type. Apply anti-gaming heuristics (strawman alternatives, trivial falsification, hypothesis ≈ implementation, fake uncertainty inventory, hypothesis too broad). For delivery stories: verify the discovery exit contract is met.
- **Must not do:** Approve a PR without a linked ST-\*. Accept "tests pass" as sufficient evidence. Approve delivery stories when the discovery exit contract is not met.

## Fast-lane

**The default is fast-lane. Full CLD is the exception that earns its way in.**

Triage by reversibility × blast radius:

|                  | Small blast radius     | Large blast radius     |
| ---------------- | ---------------------- | ---------------------- |
| **Easy to undo** | Fast-lane              | Fast-lane + extra care |
| **Hard to undo** | Fast-lane + extra care | Full CLD               |

**Use fast-lane for:** bug fixes, refactors, dependency updates, config changes — anything where the verification is deterministic. The test suite is already the falsification mechanism.

**Use full CLD for:** data models, public APIs, cross-feature integrations, security boundaries — anything where a wrong assumption is expensive to reverse or has wide impact.

Fast-lane still requires:

- Expected effect statement
- Test evidence (or explicit justification for why no new test is needed)
- Rollback consideration

Mark PR body with `[fast-lane]` and a one-line justification.

**Example:** `[fast-lane]` Bump X from 1.1 to 1.2 for security patch CVE-XXXX. Expected: CI green, no breaking changes per changelog. Rollback: revert to 1.1.

## Backward Check

The loop closes in both directions. Forward: did we think enough to start? Backward: did what we shipped earn its keep?

Fast-lane features should be periodically reviewed for actual value vs. maintenance cost. A feature surface that grows monotonically — because nothing ever gets killed — is a sign the backward check is missing.

## Gate Checks (Phase 3)

**Pre-commit** (fast local feedback):

- `scripts/check-pr-links.sh` — commit/PR references at least one ST-\*
- `scripts/check-pr-template.sh` — required sections not empty

**CI** (non-bypassable):

- `scripts/check-story-links.sh` — referenced ST-\* contains a HYP-\* link
- `scripts/check-uncertainties.sh` — referenced HYP-\* has uncertainty inventory (≥2 independently fatal items), selected uncertainty, and at least one status update _(planned — Phase 3.x)_
- `scripts/check-falsification.sh` — referenced HYP-\* has falsification signal and alternative hypothesis
- `scripts/check-test-evidence.sh` — PR includes test change or explicit justification
- `scripts/check-discovery-exit.sh` — for delivery stories: discovery exit contract is met _(planned — Phase 3.x)_

Workflow: `.github/workflows/cld-gate-check.yml`
