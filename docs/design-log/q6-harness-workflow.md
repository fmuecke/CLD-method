> Q6: So, now let's sketch some schema or workflow that I could use with GitHub and coding agents like Codex or Codec.

A6: Yes. GitHub and current coding agents are now capable enough to host a first practical version of this.

The relevant building blocks already exist:
GitHub Copilot supports repository-wide and path-specific custom instructions, and its cloud coding agent supports `AGENTS.md`; GitHub also supports custom agent profiles in `.github/agents/*.agent.md`. GitHub Models adds prompt storage and evals, including CLI-based eval runs. On the OpenAI side, Codex supports sandbox modes, approval policies, and runs with network access off by default unless you broaden permissions. ([GitHub Docs][1])

So the right move is not to invent a huge platform. It is to define a **repository-native harness** that sits on top of:

- GitHub repo structure
- custom instructions / agents
- issues / PRs
- CI checks
- evals
- agent sandboxing

## The core design principle

Do not try to encode “Agile” into the tool.

Encode **gates around uncertainty**:

1. No implementation without a problem hypothesis.
2. No acceptance without executable examples.
3. No merge without evidence.
4. No iteration without recorded learning.

That is the harness.

---

# Proposed repository schema

Use the repo itself as the persistent state for assumptions, decisions, and evidence.

```text
.github/
  copilot-instructions.md
  agents/
    discovery.agent.md
    delivery.agent.md
    review.agent.md
  workflows/
    harness-check.yml
    agent-evals.yml

docs/
  harness/
    README.md
    glossary.md
  initiatives/
    INIT-2026-001-user-onboarding.md
  decisions/
    ADR-0001-auth-session-strategy.md
  hypotheses/
    HYP-2026-014-reduce-login-failure.md
  experiments/
    EXP-2026-008-login-error-copy.md
  evidence/
    EVID-2026-021-test-results.md
  stories/
    ST-2026-115-reset-password-flow.md

prompts/
  discovery.prompt.md
  delivery.prompt.md
  review.prompt.md
  evals/
    harness-quality.prompt.yml

src/
tests/
```

## Why this structure works

It separates six things teams usually mix together:

- **initiative** = larger problem/opportunity
- **hypothesis** = explicit assumption to test
- **story** = implementation slice
- **decision** = architectural or product commitment
- **experiment** = how uncertainty is reduced
- **evidence** = what actually happened

That is the most important modeling choice.
If you skip it, your workflow collapses back into “ticket = truth”.

---

# Minimal document schemas

Keep them small. If they are bloated, people and agents will route around them.

## 1. Initiative

`docs/initiatives/INIT-*.md`

```md
# Initiative

ID: INIT-2026-001
Title: Improve first-time user onboarding
Status: Discovery | Delivery | Validating | Done

## Problem

What user or business problem are we addressing?

## Target outcome

What observable change would indicate success?

## Non-goals

What are we explicitly not solving?

## Open assumptions

- HYP-2026-014
- HYP-2026-015

## Linked stories

- ST-2026-115
```

## 2. Hypothesis

`docs/hypotheses/HYP-*.md`

```md
# Hypothesis

ID: HYP-2026-014
Initiative: INIT-2026-001
Status: Open | In Test | Confirmed | Rejected

## Assumption

We believe that ...

## Why we think this

Signals, anecdotes, data, stakeholder input.

## How this could be wrong

What evidence would falsify it?

## Validation plan

Interview, prototype, experiment, telemetry, support data, etc.

## Success signal

What measurable observation would support this?

## Result

Confirmed / Rejected / Inconclusive
```

## 3. Story

`docs/stories/ST-*.md`

```md
# Story

ID: ST-2026-115
Initiative: INIT-2026-001
Related hypothesis: HYP-2026-014

## Slice

What thin vertical slice is implemented?

## Expected behavior

- Given ...
- When ...
- Then ...

## Test levels

- Unit:
- Integration:
- End-to-end:
- Production observation:

## Constraints

Security, performance, UX, compatibility.

## Evidence required before merge

- tests pass
- examples covered
- telemetry added
```

## 4. Evidence

`docs/evidence/EVID-*.md`

```md
# Evidence

ID: EVID-2026-021
Related to: ST-2026-115 / HYP-2026-014

## What was done

## What was observed

## Expected vs actual

## Remaining uncertainty

## Recommended next decision
```

---

# Agent split

Do not use one generic coding agent for everything.

Use three constrained roles.

## 1. Discovery agent

Purpose:

- challenge assumptions
- rewrite vague requests into hypotheses
- identify missing evidence
- generate alternatives, not code

Inputs:

- initiative
- user request
- existing hypotheses

Outputs:

- hypothesis file
- experiment suggestion
- candidate story slices

It should be explicitly forbidden from writing production code.

## 2. Delivery agent

Purpose:

- implement only from approved story slices
- write tests first or at least examples first
- update evidence stubs
- respect repo instructions

Inputs:

- story
- approved decision
- constraints
- test expectations

Outputs:

- code
- tests
- telemetry hooks
- PR draft notes

It should be forbidden from inventing scope.

## 3. Review agent

Purpose:

- inspect whether the change actually closes the intended hypothesis
- check missing tests, overreach, mismatched levels of testing
- detect assumption laundering

Inputs:

- PR diff
- linked story / hypothesis / initiative

Outputs:

- structured review:
  - requirement gap
  - test gap
  - risk
  - missing evidence

This separation maps well to GitHub custom agents and repo instructions. GitHub’s current custom-agent setup supports agent-specific prompts, tool access, and model selection in `.github/agents/*.agent.md`. ([GitHub Docs][2])

---

# Workflow

This is the actual harness loop.

## Stage 1: Discovery

Trigger:

- new issue
- product request
- support signal
- bug trend

Required artifact:

- initiative or hypothesis file

Rule:

- no story may be created unless at least one open assumption is explicit

### Example GitHub issue template

```md
## Problem statement

What problem do we believe exists?

## Who experiences it?

User, operator, internal team, system.

## Evidence

What data, examples, or anecdotes support this?

## Assumptions

What are we not sure about?

## Success signal

What would improve if we are right?

## Proposed next step

Research / experiment / slice / do nothing
```

This is where your “don’t jump to solutions” forcing function lives.

---

## Stage 2: Framing

Discovery agent produces:

- 1–3 solution options
- tradeoffs
- smallest viable slice

Rule:

- no coding until at least one alternative was considered

That rule matters because agents lock into first-plausible-solution mode very easily.

---

## Stage 3: Story gating

Before coding, a story file must exist with:

- linked hypothesis
- examples
- intended test levels
- required evidence

Rule:

- no PR without linked `ST-*`
- no `ST-*` without linked `HYP-*`

This is cheap to enforce in CI via filename/reference checks.

---

## Stage 4: Delivery

Delivery agent works in a bounded sandbox.

For Codex, the practical default is:

- `workspace-write`
- approval policy `on-request`
- network off unless clearly needed

That matches Codex’s lower-risk default posture and avoids letting the agent roam freely. ([OpenAI Entwickler][3])

Delivery flow:

1. read story and hypothesis
2. derive executable examples
3. implement smallest slice
4. add or update tests
5. add telemetry / logs / counters if needed
6. update evidence stub
7. open PR

---

## Stage 5: Review

PR template should require:

```md
## Linked artifacts

- Initiative:
- Hypothesis:
- Story:
- Decision:

## What assumption does this change address?

## What examples prove expected behavior?

## What was tested at each level?

- Unit
- Integration
- E2E
- Manual exploratory
- Production observation plan

## What remains uncertain?

## How will we know this worked after release?
```

Now the review is not “does the code look okay?”
It becomes “does this change trace back to a valid uncertainty-reduction step?”

---

## Stage 6: Merge gate

CI should fail if:

- no linked story
- no linked hypothesis
- no executable examples/tests
- no evidence section
- no post-release observation plan for user-facing changes

This is the core forcing function.

---

## Stage 7: Learning

After merge or release:

- evidence file updated
- hypothesis status updated
- next step chosen:
  - confirm
  - reject
  - refine
  - open new hypothesis

No learning artifact, no closure.

That is how you prevent “iteration = activity”.

---

# Concrete GitHub files

## `.github/copilot-instructions.md`

This should define the repo-wide behavioral contract for agents.

Example:

```md
# Repository harness instructions

This repository uses a hypothesis-driven workflow.

## General rules

- Do not implement from vague requests.
- Do not treat a story as truth; trace it back to a linked hypothesis.
- Prefer the smallest vertical slice that reduces uncertainty.
- Do not expand scope beyond the linked story.
- Surface ambiguities explicitly instead of silently filling gaps.

## Before coding

You must identify:

- linked initiative
- linked hypothesis
- linked story
- expected behavior examples
- required test levels

If any are missing, stop and ask for them or propose a draft artifact.

## Testing

Do not rely only on end-to-end tests.
Choose tests deliberately:

- unit for local logic
- integration for contracts and boundaries
- end-to-end for critical journeys only

## Evidence

For user-facing or risky changes, include:

- how success will be observed after release
- telemetry or logs if needed
- expected vs actual summary in PR notes
```

GitHub supports repository custom instructions specifically to guide Copilot on how to understand the project and how to build, test, and validate changes. ([GitHub Docs][1])

---

## `.github/agents/discovery.agent.md`

```md
---
name: Discovery Agent
description: Turns requests into hypotheses, alternatives, and smallest useful slices.
tools: [repo, search, edit]
model: gpt-5
---

You are the discovery agent.

You do not write production code.

Your job is to:

1. identify the actual problem being claimed
2. separate facts from assumptions
3. create or update initiative and hypothesis files
4. propose 2-3 solution directions
5. recommend the smallest next slice that reduces uncertainty

Reject solutioning when the problem statement is weak.
Ask: what evidence would prove this wrong?
```

## `.github/agents/delivery.agent.md`

```md
---
name: Delivery Agent
description: Implements thin slices from approved stories with tests and evidence.
tools: [repo, terminal, edit, test]
model: gpt-5
---

You are the delivery agent.

You may only implement from an existing story file linked to a hypothesis.

Rules:

- do not invent scope
- derive behavior examples first
- prefer the smallest possible change
- write or update tests appropriate to the risk
- add production observation hooks where required
- update evidence stub before finishing
```

## `.github/agents/review.agent.md`

```md
---
name: Review Agent
description: Reviews changes for traceability, test adequacy, and missing uncertainty.
tools: [repo, diff, comments]
model: gpt-5
---

You are the review agent.

Review for:

- missing hypothesis linkage
- assumption laundering
- overreach beyond story
- wrong test level
- missing production evidence plan
- mismatch between stated problem and implemented change

Output sections:

1. Traceability
2. Test strategy
3. Remaining risk
4. Recommendation
```

---

# CI harness checks

A lightweight GitHub Actions workflow is enough for v1.

## `harness-check.yml`

Checks:

- PR references `ST-*`
- story file references `HYP-*`
- changed code has corresponding tests, if applicable
- PR template sections completed
- hypothesis/evidence docs updated for designated change types

Pseudo-logic:

```yaml
name: Harness Check

on:
  pull_request:

jobs:
  harness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Verify PR references story
        run: ./scripts/check-pr-links.sh

      - name: Verify story references hypothesis
        run: ./scripts/check-story-links.sh

      - name: Verify required PR sections
        run: ./scripts/check-pr-template.sh

      - name: Verify tests or justification
        run: ./scripts/check-test-evidence.sh
```

Start with dumb text checks.
Do not overengineer this initially.

---

# Evals layer

This is the piece most teams miss.

You do not only need evals for the product.
You also need evals for the **agent behavior**.

GitHub Models supports storing prompts in-repo and evaluating prompts/models, including with `gh models eval` in CI. ([GitHub Docs][4])

## What to evaluate

1. **Discovery quality**
   - Did the agent identify assumptions?
   - Did it separate problem from solution?

2. **Delivery quality**
   - Did it honor scope boundaries?
   - Did it add correct test levels?

3. **Review quality**
   - Did it detect missing traceability?
   - Did it spot overreliance on E2E?

## Example eval cases

Store a small corpus of historical examples:

```yaml
prompts:
  - file: prompts/discovery.prompt.md

tests:
  - vars:
      request: "Users complain the login is broken. Add SSO."
    assert:
      - type: contains
        value: "assumption"
      - type: contains
        value: "evidence"
      - type: contains
        value: "alternative"

  - vars:
      request: "Build export to PDF."
    assert:
      - type: contains
        value: "success signal"
```

That lets you tune the harness, not just the code.

---

# Operating model

This is the minimal human workflow:

## Product / requester

Creates or updates:

- initiative
- problem statement
- success signal

## Discovery agent + human

Refines:

- hypotheses
- alternatives
- experiments
- smallest slices

## Delivery agent + developer

Creates:

- code
- tests
- telemetry
- PR notes

## Review agent + reviewer

Checks:

- traceability
- test strategy
- residual risk

## Team

Closes the loop by updating:

- evidence
- hypothesis status
- next decision

That is lightweight enough to run.

---

# What not to do

Three common failure modes:

## 1. Do not make the story template huge

If it feels like compliance paperwork, it will be bypassed.

## 2. Do not force every tiny refactor through full discovery

Use a fast lane for:

- obvious bug fixes
- internal refactors
- dependency updates

But even there, still require:

- expected effect
- test evidence
- rollback thought

## 3. Do not let the agent write from issue text alone

That is how you recreate waterfall, only faster.

---

# Recommended first version

Start with this narrow scope:

1. one repo
2. one `copilot-instructions.md`
3. three agent profiles
4. one story template
5. one hypothesis template
6. one PR template
7. one simple CI harness check

That is enough to test whether behavior changes.

---

# The short version of the workflow

```text
Issue
  -> Initiative
  -> Hypothesis
  -> Alternatives
  -> Small Story Slice
  -> Examples / Test Intent
  -> Agent Implementation
  -> PR with Evidence Plan
  -> CI Harness Check
  -> Review
  -> Merge
  -> Observe
  -> Update Evidence / Hypothesis
```

That is your harness.

If you want, next I can turn this into actual ready-to-commit files for a GitHub repo:

- `copilot-instructions.md`
- three `.agent.md` files
- issue template
- PR template
- `harness-check.yml` skeleton

[1]: https://docs.github.com/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot "Adding repository custom instructions for GitHub Copilot - GitHub Docs"
[2]: https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents "Creating custom agents for Copilot cloud agent - GitHub Docs"
[3]: https://developers.openai.com/codex/concepts/sandboxing "Sandboxing – Codex | OpenAI Developers"
[4]: https://docs.github.com/github-models "GitHub Models - GitHub Docs"
