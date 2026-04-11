# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See `AGENTS.md` for the full CLD behavioral contract — workflow, artifact types, agent roles, smallest possible test principle, and gate checks.

## Claude Code Role Selection

When given a task, identify which CLD role applies and operate within its constraints:

- **Discovery** — vague request, new problem, hypothesis not yet written → see `docs/cld/agents/discovery.md`
- **Delivery** — approved ST-*.md exists with a HYP-* link → see `docs/cld/agents/delivery.md`
- **Review** — PR open with linked ST-*, HYP-*, EVID-* → see `docs/cld/agents/review.md`

If the role is unclear, ask before proceeding.

## Repository Structure

```
AGENTS.md                             — CLD behavioral contract (single source of truth)
docs/initiatives/     INIT-*.md       — problems/opportunities
docs/hypotheses/      HYP-*.md        — hypotheses with smallest possible test
docs/stories/         ST-*.md         — stories; expected behavior IS the test spec
docs/decisions/       ADR-*.md        — architectural commitments
docs/experiments/     EXP-*.md        — how uncertainty is reduced
docs/evidence/        EVID-*.md       — expected vs actual; must end with a decision
docs/cld/agents/                      — canonical agent role definitions (platform-neutral)
docs/cld/templates/                   — document templates
.github/agents/       *.agent.md      — GitHub Copilot agent profiles
scripts/                              — gate check scripts
prompts/evals/                        — agent eval test cases
```

## Phase Status

| Phase | Goal | Status |
|-------|------|--------|
| 0 | Repo skeleton + document templates | Done |
| 1 | AGENTS.md + agent profiles on Copilot, Claude Code, Codex | Done |
| 2 | GitHub issue/PR templates + fast-lane definition | Not started |
| 3 | Gate checks: pre-commit hooks + CI | Not started |
| 4 | Pilot with real feature work | Not started |
| 5 | Agent evals across platforms | Not started |

## Key Source Files

- `cld-project-plan.md` — Master plan with full phase breakdown and success criteria
- `q2.md` — How AI amplifies development failures; refined CLD thesis
- `q3.md` — Non-negotiable harness properties and cognitive load rationale
- `q9-hypo-builder.md` — Hypothesis builder guidance; source for the 5-question preamble in HYP template
