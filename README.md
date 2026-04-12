# Closed-Loop Delivery (CLD)

> Every gate asks one question: did you reduce enough uncertainty to continue?

CLD is a system of skeptical forcing functions that prevents AI agents and humans from skipping the uncomfortable parts of software development: stating assumptions, exploring alternatives, defining what would prove them wrong, and validating before committing.

**The problem it solves:** AI removes execution cost but amplifies the cost of wrong assumptions. Agents optimize for task completion, not assumption validation. "Correct code for the wrong problem" is now the dominant failure mode.

**The bet:** If epistemic discipline — explicit assumptions, falsification-first testing, evidence capture — is embedded in the repository structure itself rather than left to individual willpower, teams will build the right thing more often.

## How It Works

Every piece of work follows a traceable chain:

```
Issue → INIT → HYP → ST → IMPL → PR → Review → EVID
```

| Artifact | What it is                                                                                                    |
| -------- | ------------------------------------------------------------------------------------------------------------- |
| `INIT-*` | The problem — described as pain, not as a solution                                                            |
| `HYP-*`  | A falsifiable assumption with a falsification signal, an alternative hypothesis, and a smallest possible test |
| `ST-*`   | A bounded implementation slice — the expected behavior _is_ the test spec                                     |
| `IMPL`   | The code change — must reference a `ST-*`                                                                     |
| `EVID-*` | What actually happened — expected vs actual, ending with a decision                                           |

No step can be bypassed without explicit justification. The chain is the constraint.

## Three Agent Roles

Work in the role that matches the task:

- **Discovery** — surface assumptions, produce falsification signals and alternatives, never write production code
- **Delivery** — implement exactly what the story specifies, write the test that matches the falsification signal first
- **Review** — verify the chain, flag assumption laundering, coverage theater, and anti-gaming patterns

Full role definitions: [`docs/cld/agents/`](docs/cld/agents/)

## Gate Checks

Two enforcement layers:

**Pre-commit** (local, fast): commit message must reference a `ST-*` or be marked `[fast-lane]`.

**CI** (non-bypassable): story links to a hypothesis, hypothesis has a falsification signal and alternative, test evidence is present. Anti-gaming heuristics run as warnings.

```bash
# Install pre-commit hook
bash scripts/install-hooks.sh
```

## Fast-lane

**The default is fast-lane.** Full CLD is the exception that earns its way in. Triage by reversibility × blast radius:

|                  | Small blast radius     | Large blast radius     |
| ---------------- | ---------------------- | ---------------------- |
| **Easy to undo** | Fast-lane              | Fast-lane + extra care |
| **Hard to undo** | Fast-lane + extra care | Full CLD               |

Reversible, low-risk changes (dependency updates, bug fixes, refactors) skip full discovery. Still required: expected effect, test evidence, rollback consideration. Mark the PR with `[fast-lane]`.

Operational changes where verification is deterministic — "does it break?" — don't generate hypotheses. The test suite is already the falsification mechanism.

## Getting Started

1. **New problem** → open a [CLD Initiative issue](.github/ISSUE_TEMPLATE/cld-issue.md) and create `docs/initiatives/INIT-YYYY-NNN.md`
2. **Not enough to hypothesize yet** → open a [CLD Exploration issue](.github/ISSUE_TEMPLATE/cld-exploration.md) with a time box
3. **Ready to build** → create `docs/hypotheses/HYP-YYYY-NNN.md` and `docs/stories/ST-YYYY-NNN.md` from the [templates](docs/cld/templates/)
4. **Implementing** → write the test that matches the falsification signal first, then open a PR using the [PR template](.github/pull_request_template.md)
5. **Done** → fill in `docs/evidence/EVID-YYYY-NNN.md` with expected vs actual and a decision

## Repository Layout

```
AGENTS.md                   CLD behavioral contract (read this first)
cld-project-plan.md         Full project plan and design rationale
docs/
  initiatives/              INIT-*.md
  hypotheses/               HYP-*.md
  stories/                  ST-*.md
  evidence/                 EVID-*.md
  decisions/                ADR-*.md (cross-cutting decisions)
  experiments/              EXP-*.md (exploration outputs)
  cld/
    agents/                 Platform-neutral agent role definitions
    templates/              Document templates
    boundaries.md           What CLD does not claim to solve
  design-log/               Archived design Q&A; rationale behind decisions
.github/
  agents/                   GitHub Copilot agent profiles
  ISSUE_TEMPLATE/           Issue templates (initiative, exploration)
  pull_request_template.md  PR template with gate questions and decision record
  workflows/
    cld-gate-check.yml      CI gate enforcement
scripts/                    Gate check scripts
```

## Known Boundaries

CLD targets assumption-driven failure. It does not claim to solve integration complexity, organizational incentives, tacit knowledge, or time-to-market pressure. See [`docs/cld/boundaries.md`](docs/cld/boundaries.md).

---

_Author: Florian Mücke_
