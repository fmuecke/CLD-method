# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

**Closed-Loop Delivery (CLD)** is a repository-native constraint system that prevents AI agents and humans from skipping critical validation steps in software development. The core thesis: AI removes execution cost but amplifies the cost of wrong assumptions. CLD embeds epistemic discipline — explicit assumptions, forced validation, evidence capture — into repo structure and agent interactions.

This repository is currently in the **design/research phase**. It contains conceptual framework documentation. Implementation begins in Phase 0 (repo skeleton + templates).

## Repository Structure

```
docs/initiatives/     INIT-*.md   — problems/opportunities
docs/hypotheses/      HYP-*.md   — explicit assumptions to test
docs/stories/         ST-*.md   — bounded implementation slices
docs/decisions/       ADR-*.md    — architectural commitments
docs/experiments/     EXP-*.md    — how uncertainty is reduced
docs/evidence/        EVID-*.md   — what actually happened
docs/cld/agents/                  — canonical agent role definitions (platform-neutral)
docs/cld/templates/               — document templates
.github/agents/       *.agent.md  — GitHub Copilot agent profiles
scripts/                          — CI gate check scripts
prompts/evals/                    — agent eval test cases
```

## Gate Abbreviations

All artifact prefixes use exactly 4 letters:

| Abbrev | Type           | Purpose                      |
| ------ | -------------- | ---------------------------- |
| INIT   | Initiative     | Problem/opportunity framing  |
| HYP    | Hypothesis     | Explicit assumption to test  |
| ST     | Story          | Bounded implementation slice |
| IMPL   | Implementation | Code change (PR/commit)      |
| EVID   | Evidence       | What actually happened       |

## Agent Roles

This project defines three constrained agent modes. When working in this repo, operate in the role that matches the current task:

### Discovery Agent

- **Purpose:** Challenge vague requests, surface assumptions, generate 2–3 competing options with tradeoffs
- **Allowed outputs:** INIT-_.md, HYP-_.md, framing documents, alternatives analysis
- **Hard constraint:** No production code. No stories without explicit hypotheses.

### Delivery Agent

- **Purpose:** Implement only from an approved ST-\*.md. Tests first, then code.
- **Allowed outputs:** Code, tests, EVID-\*.md
- **Hard constraint:** No scope invention. Every change must trace back to a story. Every story must link to a HYP-\*.md.

### Review Agent

- **Purpose:** Verify traceability, detect assumption laundering, check test strategy, identify remaining risk
- **Outputs:** Review commentary, gap reports, remaining uncertainty statements
- **Hard constraint:** Cannot approve work that lacks HYP → ST → EVID chain.

## Workflow Gates

The mandatory flow is: **Issue → INIT → HYP → ST → IMPL → PR → Review → EVID**

No step can be bypassed without explicit justification. Before moving to implementation ask: _"What assumption does this code test?"_ If you cannot answer that, return to discovery.

**Fast-lane** (for bug fixes, refactors, dependency updates): Skip full discovery, but must still include expected effect statement, test evidence, and rollback consideration.

## Gate Checks (Phase 3 target)

Two layers: pre-commit hooks for fast local feedback, CI for non-bypassable enforcement.

**Pre-commit** (local, bypassable with `--no-verify` — catches honest mistakes):

- `scripts/check-pr-links.sh` — commit message references at least one `ST-*`
- `scripts/check-pr-template.sh` — required sections not empty/placeholder

**CI** (server-side, cannot be skipped — needs repo context for cross-file checks):

- `scripts/check-story-links.sh` — referenced story file contains a `HYP-*` link
- `scripts/check-test-evidence.sh` — PR includes at least one test change mapping to the story behavior, or explicit justification; validates presence, not coverage metrics

Wired together in `.github/workflows/cld-gate-check.yml`.

## Document Templates

See `docs/cld/templates/` for full templates. Minimal schemas:

### INIT-\*.md (Initiative)

Problem statement, who experiences it, evidence it exists, assumptions, success signal.

### HYP-\*.md (Hypothesis)

Assumption being tested, how it will be validated, what outcome would falsify it, linked INIT.

### ST-\*.md (Story)

Linked HYP, acceptance criteria (as executable examples where possible), scope boundary.

### EVID-\*.md (Evidence)

What was built, what was tested, what results showed, what remains uncertain, next decision.

## Key Design Principles

1. **Assumption gating** — No work without explicit assumptions
2. **Validation before elaboration** — Cannot increase detail without reducing uncertainty
3. **Mandatory alternatives** — 2–3 competing options before commitment
4. **Smallest possible test** — Every hypothesis and story must define the cheapest test that confirms or rejects it; test level chosen by what validates the claim, not by convention or coverage targets
5. **Evidence capture** — Every iteration produces: expected vs actual result + remaining uncertainty + next decision

## Phase Status

| Phase | Goal                                             | Status      |
| ----- | ------------------------------------------------ | ----------- |
| 0     | Repo skeleton + document templates               | In progress |
| 1     | Agent profiles on Copilot, Claude Code, Codex    | Not started |
| 2     | GitHub issue/PR templates + fast-lane definition | Not started |
| 3     | CI gate checks                                   | Not started |
| 4     | Pilot with real feature work                     | Not started |
| 5     | Agent evals across platforms                     | Not started |

## Instruction File Strategy (Phase 1 target)

`AGENTS.md` at repo root will be the single source of truth for CLD rules (supported natively by Codex, Cursor, Copilot, Gemini CLI, and others). Once created:

- `CLAUDE.md` → `See @AGENTS.md for CLD rules.` (plus Claude-specific overrides only)
- `.github/copilot-instructions.md` → mirrors/references `AGENTS.md`
- Codex reads `AGENTS.md` natively — no extra file needed

## Key Source Files

- `cld-project-plan.md` — Master plan with full phase breakdown and success criteria
- `q6-harness-workflow.md` — Concrete GitHub workflow, agent roles, CI checks
- `q2.md` — How AI amplifies development failures; refined CLD thesis
- `q3.md` — Non-negotiable harness properties and cognitive load rationale
- `q5-existing-solutions.md` — Gap analysis vs existing tools
