# Project: Closed-Loop Delivery (CLD)

> The goal is not iteration. The goal is a closed loop where every step produces
> evidence, and progress is only allowed when that evidence reduces uncertainty.

## Working Hypothesis

> AI coding agents remove execution cost but amplify the cost of wrong assumptions.
> If we embed epistemic discipline (explicit assumptions, forced validation, evidence capture)
> into the repository structure and agent interactions, teams will build the right thing more
> often — without relying on individual willpower.

## Why This Is Worth Solving

1. **The problem is real and well-documented.**
   Every V-model stage has a known cognitive bias (premature convergence, assumption laundering,
   coverage illusion, etc.). Agile/XP identified the countermeasures decades ago. Adoption remains
   inconsistent because the practices are optional and humans skip them under cognitive load.

2. **AI makes it worse before it makes it better.**
   Spec-driven AI workflows reproduce waterfall at higher speed. Agents optimize for task
   completion, not assumption validation. "Correct code for the wrong problem" is now the
   dominant failure mode.

3. **The gap is clear and unfilled.**
   Existing tools cover fragments — guardrails enforce format, agent frameworks manage execution,
   CI validates code quality — but nothing connects them around _uncertainty management_.
   No tool today prevents skipping the thinking.

4. **The building blocks exist.**
   GitHub custom instructions, agent profiles (`.agent.md`), CI workflows, and sandbox-capable
   agents (Copilot, Codex, Claude Code) provide enough infrastructure. This is an integration
   and constraint problem, not a platform problem.

5. **It's testable with one repo and one team.**
   CLD is repo-native by design. No new platform needed. Success or failure becomes
   visible within weeks, not months.

## What Success Looks Like

- Assumptions are explicit and traceable from issue to merge.
- Agents cannot bypass hypothesis → story → evidence flow.
- Teams report fewer "built the wrong thing" incidents.
- The overhead feels lighter than the rework it prevents.

## Risks & Constraints

| Risk                                               | Mitigation                                                    |
| -------------------------------------------------- | ------------------------------------------------------------- |
| Templates feel like compliance paperwork           | Keep schemas minimal; fast-lane for trivial changes           |
| Over-constraining kills exploration                | Enforce _thinking quality_, not artifacts                     |
| Agent instructions are advisory, not hard gates    | CI checks as the real enforcement layer                       |
| Non-formalizable uncertainty (user value, context) | Hybrid: tool-enforced constraints + human validation loops    |
| Platform fragmentation across agents               | Single-source role definitions, platform-specific projections |

## Target Environment

- **Repo:** Fresh greenfield repo for evaluation — no legacy constraints.
- **Agent platforms (all in scope):**

| Platform       | Instruction mechanism                                           | Role separation                            |
| -------------- | --------------------------------------------------------------- | ------------------------------------------ |
| GitHub Copilot | `.github/copilot-instructions.md` + `.github/agents/*.agent.md` | Native agent profiles                      |
| Claude Code    | `CLAUDE.md` (repo root + subdirectory overrides)                | Role via prompt sections or slash commands |
| OpenAI Codex   | `AGENTS.md` + sandbox policies                                  | Task-scoped agents                         |

- **Design principle:** Author role definitions (discovery, delivery, review) once in a
  canonical format under `docs/cld/agents/`. Then project them into each platform's
  native format. This avoids drift and lets us compare agent behavior across platforms.

---

# Build Plan

## Phase 0 — Foundation (Week 1)

**Goal:** Repo skeleton + core documents. Nothing automated yet. Just the structure.

### Steps

0.1. Create a fresh GitHub repo dedicated to CLD evaluation.

0.2. Add the `docs/cld/` folder structure:

- `docs/initiatives/`
- `docs/hypotheses/`
- `docs/stories/`
- `docs/evidence/`
- `docs/decisions/`
- `docs/experiments/`
- `docs/cld/agents/` — canonical role definitions (platform-neutral)

0.3. Write minimal document templates (1 each):

- Initiative (`INIT-*.md`)
- Hypothesis (`HYP-*.md`)
- Story (`ST-*.md`)
- Evidence (`EVID-*.md`)

0.4. Write canonical agent role definitions (platform-neutral):

- `docs/cld/agents/discovery.md` — purpose, inputs, outputs, constraints
- `docs/cld/agents/delivery.md`
- `docs/cld/agents/review.md`

0.5. Write one real example through the full chain:

- Pick a small, realistic feature (e.g. a CLI tool, a small API endpoint).
- Create INIT → HYP → ST → EVID files manually.
- This validates the schema before any automation.

### Exit criteria

- One complete example chain exists and feels lightweight enough to use.

---

## Phase 1 — Agent Profiles (Week 2)

**Goal:** Project canonical role definitions into platform-specific instruction files. Test on all target platforms.

### Steps

1.1. **GitHub Copilot projection:**

- `.github/copilot-instructions.md` — repo-wide behavioral contract
- `.github/agents/discovery.agent.md` — no production code, hypothesis focus
- `.github/agents/delivery.agent.md` — story-scoped, tests-first
- `.github/agents/review.agent.md` — traceability and gap detection

1.2. **Claude Code projection:**

- `CLAUDE.md` at repo root — repo-wide CLD rules
- Role-specific sections or subdirectory overrides where applicable
- Discovery/delivery/review separation via explicit prompt context

1.3. **OpenAI Codex projection:**

- `AGENTS.md` at repo root — behavioral contract
- Sandbox policy: `workspace-write`, approval `on-request`, network off by default

1.4. **Cross-platform test** against the Phase 0 example:

- Feed the same initiative to discovery role on each platform.
- Feed the same story to delivery role on each platform.
- Compare: does each platform respect the constraints?
- Document behavioral differences in `docs/cld/platform-notes.md`.

### Exit criteria

- Each agent role behaves noticeably different from a generic coding agent — on every platform.
- Discovery refuses to code. Delivery refuses to invent scope. Review catches gaps.
- Platform-specific quirks are documented.

---

## Phase 2 — GitHub Templates & PR Contract (Week 2–3)

**Goal:** Structural forcing functions via GitHub native features.

### Steps

2.1. Create issue template (`.github/ISSUE_TEMPLATE/cld-issue.md`):

- Problem statement, who experiences it, evidence, assumptions, success signal.

2.2. Create PR template (`.github/pull_request_template.md`):

- Linked references (initiative, hypothesis, story).
- What assumption does this address?
- What was tested at each level?
- What remains uncertain?
- Post-release observation plan.

2.3. Define fast-lane criteria:

- Which change types (bug fixes, refactors, deps) can skip full discovery?
- Even fast-lane requires: expected effect, test evidence, rollback thought.

### Exit criteria

- Every new issue and PR is guided by the template.
- Fast-lane exists and doesn't feel like cheating.

---

## Phase 3 — CI Gate Checks (Week 3–4)

**Goal:** Automated gates that fail PRs missing required traceability.

### Steps

3.1. Write `scripts/check-pr-links.sh`:

- PR body must reference at least one `ST-*`.

3.2. Write `scripts/check-story-links.sh`:

- Referenced story file must contain a `HYP-*` link.

3.3. Write `scripts/check-pr-template.sh`:

- Required PR sections must not be empty/placeholder.

3.4. Write `scripts/check-test-evidence.sh`:

- Changed source files should have corresponding test changes (or explicit justification).

3.5. Create `.github/workflows/cld-gate-check.yml` tying them together.

3.6. Run against 3–5 real PRs to calibrate strictness.

- Too strict → teams route around it.
- Too loose → no behavior change.

### Exit criteria

- CI fails on PRs that skip the chain. Fast-lane PRs pass with lighter checks.

---

## Phase 4 — Pilot with Real Work (Week 4–6)

**Goal:** Build a small but real feature using CLD. Compare agent behavior across platforms.

### Steps

4.1. Define 3–5 feature slices for the fresh repo (e.g. a small CLI tool, REST API, or utility library).

4.2. Run each slice through the full CLD workflow:

- Issue → Initiative → Hypothesis → Story → Implementation → PR → Review → Evidence

4.3. Rotate agent platforms across slices:

- Slice A: GitHub Copilot agents
- Slice B: Claude Code
- Slice C: Codex
- This produces comparable data on how each platform responds to the same constraints.

4.4. Track friction points per platform:

- Where do agents try to skip steps?
- Which platform respects constraints best out of the box?
- Which templates feel too heavy?
- Which CI checks produce false positives?

4.5. Conduct a retrospective specifically on CLD:

- Did it change what got built?
- Did it surface assumptions that would have been missed?
- What's the actual overhead vs perceived overhead?
- Which platform is the best fit for which role?

4.6. Refine templates, agent instructions, and CI checks based on findings.

### Exit criteria

- At least one case where the closed loop prevented building the wrong thing.
- Platform comparison documented in `docs/cld/platform-notes.md`.
- CLD does not feel like pure overhead.

---

## Phase 5 — Agent Evals (Week 6–8)

**Goal:** Systematically measure whether agents behave as intended.

### Steps

5.1. Create `prompts/evals/` with test cases for each agent role:

- Discovery: does it challenge vague requests? Does it produce alternatives?
- Delivery: does it stay within scope? Does it write tests first?
- Review: does it detect missing traceability?

5.2. Build a small eval corpus from Phase 4 real examples (across all platforms).

5.3. Run evals per platform — same inputs, compare outputs:

- GitHub Models `gh models eval` for Copilot
- Script-based for Claude Code and Codex

5.4. Use eval results to tune agent prompts per platform.

### Exit criteria

- Agent quality is measurable and improvable without guessing.

---

## Future Horizons (not in scope for v1)

### Horizon 1 — Publishable Framework

- Extract repo structure into a template repo / GitHub template.
- Write onboarding guide for teams adopting CLD.
- Possibly a CLI or GitHub Action for gate checks.

### Horizon 2 — Article / Talk

- Narrative: "We didn't need Agile because coding was hard — we needed it because
  we're systematically wrong about what to build. AI makes XP non-optional."
- Use Phase 4 evidence as the real-world proof point.
- Title candidate: "Closed-Loop Delivery: Why AI Makes XP Non-Optional"

---

# Summary

> **Closed-Loop Delivery** — a repository-native constraint system that prevents
> AI agents and humans from skipping the uncomfortable parts: stating assumptions,
> exploring alternatives, and validating before committing.
>
> Every gate asks one question: did you learn enough to continue?

---

# References

- **Author:** Florian Mücke — original concept, framework design, and project plan.
- The "harness" metaphor that informed early thinking on this project:
  Henrique Bastos, [Making Sense of Harness Engineering](https://www.linkedin.com/pulse/making-sense-harness-engineering-henrique-bastos-ezotf/)
- Kent Beck, _Extreme Programming Explained_ — the intellectual foundation for
  why feedback loops and forcing functions matter more than process artifacts.
