# Project: Closed-Loop Delivery (CLD) — v4

> **AI makes building cheap but doesn't make being wrong cheaper.**

CLD is a repo-native system of structured probes and enforceable gates. The repo
carries not just behavior but decision history and discarded paths.

## Working Hypothesis

> AI coding agents remove execution cost but amplify the cost of wrong assumptions.
> If we embed structured skepticism (explicit assumptions, forced validation, evidence capture)
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

3. **"Just ship it" works — until it doesn't.**
   When AI makes building cheap, an evolutionary approach becomes tempting: build
   more, ship fast, let the market decide what survives. And it genuinely works —
   teams _are_ successful this way, often enough to reinforce the pattern. The problem
   is that the feedback loop is open on the back end. Features ship, but nobody
   tracks which bets paid off. Nothing gets killed because killing feels riskier than
   keeping. The result is a feature surface that grows monotonically: cross-feature
   dependencies multiply, maintainability cost compounds, and the team slowly loses
   the speed advantage that justified skipping the thinking in the first place.

   CLD doesn't argue against building fast. It argues that _learning from what you
   built_ must be as systematic as building it. The closed loop closes in both
   directions: forward (did we think enough to start?) and backward (did what we
   shipped earn its keep?). Without the backward check, evolutionary delivery
   produces feature swamps, not survival of the fittest.

4. **The gap is clear and unfilled.**
   Existing tools cover fragments — guardrails enforce format, agent frameworks manage execution,
   CI validates code quality — but nothing connects them around _uncertainty management_.
   No tool today prevents skipping the thinking.

5. **The building blocks exist.**
   GitHub custom instructions, agent profiles (`.agent.md`), CI workflows, and sandbox-capable
   agents (Copilot, Codex, Claude Code) provide enough infrastructure. This is an integration
   and constraint problem, not a platform problem.

6. **It's testable with one repo and one team.**
   CLD is repo-native by design. No new platform needed. Success or failure becomes
   visible within weeks, not months.

## What Success Looks Like

- Assumptions are explicit and traceable from issue to merge.
- Agents cannot bypass uncertainty → hypothesis → story → evidence flow.
- Discovery produces ranked uncertainties before any hypothesis is written.
- Teams report fewer "built the wrong thing" incidents.
- Features that shipped are periodically reviewed for actual value vs. maintenance cost.
- The overhead feels lighter than the rework it prevents.

## What CLD Is

CLD treats hypotheses as source code for uncertainty. They compile into structured
probes, CI enforces the gates at runtime, review interprets the results.

### Probes, not just tests

A **probe** is any mechanism that reduces uncertainty about a hypothesis.

- **Verification probes** — automated: unit tests, integration tests, CI checks.
- **Validation probes** — experimental: observations, runtime metrics, usage data,
  release experiments.

Calling everything "tests" collapses a critical distinction. A passing unit test
proves implementation consistency. It usually cannot prove user value. CLD keeps
the distinction explicit so the evidence type matches the claim type.

### Three enforcement layers

| Layer        | What it does                                              | Automatable? |
| ------------ | --------------------------------------------------------- | ------------ |
| Structural   | Links exist, fields filled, traceability chain intact     | Yes (CI)     |
| Executable   | Probes run, results attached, evidence recorded           | Mostly (CI)  |
| Interpretive | Results actually discriminate, hypothesis updated soundly | No (review)  |

Most frameworks stop at layer 1. Layer 2 makes gaming harder — you can fake a
document, you can't easily fake a discriminating probe result.

### The system includes its dead ends

The repo is not just working code. It is:

> **behavior + decision history + discarded paths**

Failed and falsified hypotheses are first-class artifacts. They persist by default
so teams don't re-explore the same dead ends. To archive a superseded hypothesis:
set `Status: Archived` and fill in `Archive reason:` in the HYP frontmatter. The
file stays in `docs/hypotheses/` — nothing moves to a trash folder. The decision
trail is part of the system's value, not cleanup noise.

## Core Principle: Every Step Targets the Highest-Value Uncertainty Next

> Every next step is blocked until a specific uncertainty has been reduced.
> Every step must target the highest-value uncertainty next — the one with the
> most risk reduced per effort. This prevents random exploration, over-analysis,
> and premature convergence alike.

This principle applies at every level:

- **Discovery** → "What don't we know that could kill this?" → rank uncertainties
  by risk × effort → select the cheapest high-risk probe first.
- **Hypothesis** → "What would prove this wrong?" → that question defines the probe.
  Every hypothesis must reference the specific uncertainty it addresses.
- **Story** → expected behavior (Given/When/Then) _is_ the test spec, not a separate artifact.
  During discovery, stories can be probes (evidence-first, not feature-first).
- **Implementation** → write the test that validates the behavior, then implement against it.
- **Evidence** → probe result = expected vs actual = confirmation or rejection.
  A probe result is not validation. Validation is an interpretation step over the evidence.
  After each evidence: update the uncertainty list, then decide — continue discovery or exit to delivery.
- **Review** → doesn't ask "is coverage high enough?" — asks "does the probe actually
  falsify the hypothesis if the result is negative?"

Probe type (unit test, integration test, E2E, manual observation, runtime metric,
release experiment) is chosen by what's simplest to validate the claim — not by
convention, not by coverage targets. A well-chosen integration test that proves the
behavior beats 50 unit tests that prove implementation details. A usage metric may
be the only valid probe for a value hypothesis.

This kills the coverage illusion: you're not optimizing for lines covered,
you're optimizing for **uncertainty reduced per probe**.

## Design Philosophy: Skeptical Forcing Functions

CLD uses two kinds of gates:

### Hard gates (CI-enforced)

Structural requirements that block progress when missing. These catch omissions, not quality:

- Missing hypothesis reference
- No uncertainty inventory in HYP-\* (at least 2 items that could each independently invalidate the approach, ranked)
- No selected uncertainty identified
- No falsification signal defined
- No test or observation plan
- No reversal trigger on irreversible decisions

### Soft gates (review-enforced)

Judgment calls that require human or review-agent assessment:

- Is the selected uncertainty actually the highest value (most risk reduced per effort)?
- Is the probe the cheapest way to test it, or disguised implementation?
- Is the falsification signal actually discriminating?
- Is the alternative hypothesis a real competitor or a strawman?
- Does the evidence type match the hypothesis type?
- Is the interpretation of results sound?

**The distinction matters.** Hard gates prevent skipping. Soft gates prevent gaming.
Neither alone is sufficient. CI guarantees traceability. Review guards truth.

## Known Boundaries

CLD explicitly targets **assumption-driven failure** in agent-assisted development.
It does not claim to solve:

- **Integration complexity / operational brittleness** — different failure mode, different tools.
- **Organizational incentives** — CLD is repo-level, not org-change. If incentives reward
  shipping fast over being right, people will route around any process.
- **Tacit knowledge** — architecture intuition, UX feel, "this smells wrong" don't compress
  into HYP → ST → TEST → EVIDENCE. CLD handles the formalizable subset. Senior judgment
  remains the last gate.
- **Time-to-market pressure** — CLD adds friction. The bet is that this friction costs less
  than the rework it prevents. Phase 4 must validate this.

These boundaries should be documented in `docs/cld/boundaries.md` and revisited after
the pilot.

## Risks & Constraints

| Risk                                                         | Mitigation                                                                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| Templates feel like compliance paperwork                     | Keep schemas minimal; fast-lane for trivial/reversible changes                                                     |
| Over-constraining kills exploration                          | Explicit exploration mode; enforce _thinking quality_, not artifacts                                               |
| Agent instructions are advisory, not hard gates              | CI checks as the real enforcement layer                                                                            |
| Non-formalizable uncertainty (user value, context)           | Hybrid: hard gates for structure + soft gates for judgment                                                         |
| Platform fragmentation across agents                         | Single-source role definitions, platform-specific projections                                                      |
| **Agents generate compliant nonsense**                       | **Anti-gaming heuristics in review; falsification + alternative hypothesis as structural requirements**            |
| **Validation illusion (test passes ≠ hypothesis confirmed)** | **Falsification criteria force thinking about false positives; hypothesis typing flags evidence/claim mismatches** |
| **Goodhart's Law on artifacts**                              | **Gate questions, not document checklists; review checks meaning, CI checks structure**                            |
| **Premature hypothesis (skipping uncertainty reduction)**    | **Discovery micro-loop: uncertainty inventory required before HYP; embedded in HYP-\* for low friction**           |

## Target Environment

- **Repo:** Fresh greenfield repo for evaluation — no legacy constraints.
- **Agent platforms (all in scope):**

| Platform       | Instruction mechanism                                                         | Role separation                                            |
| -------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------- |
| GitHub Copilot | `.agents/skills/` (also accepts `.github/skills`, `.claude/skills`)           | Skills; thin `.github/agents/*.agent.md` wrappers optional |
| Claude Code    | `.agents/skills/` or `.claude/skills/`; `CLAUDE.md` for Claude-only overrides | Skills + slash commands                                    |
| OpenAI Codex   | `.agents/skills/` (scanned from CWD up to repo root); `AGENTS.md`             | Skills; task-scoped agents                                 |

- **Design principle:** Author role definitions (discovery, delivery, review) once as
  `SKILL.md` files under `.agents/skills/`. `AGENTS.md` is the lightweight behavioral
  contract (repo-wide rules, what every platform reads). Platform-specific files are thin
  wrappers only — they reference the skills, not duplicate them. This is one authoring
  location, three platforms.

  ```
  AGENTS.md                    → repo-wide contract (all platforms read this)
  .agents/skills/              → cross-platform skill location
    cld-discovery/SKILL.md     → discovery role + workflow
    cld-delivery/SKILL.md      → delivery role + workflow
    cld-review/SKILL.md        → review role + anti-gaming heuristics
  ```

  Skills can bundle gate-check script references, templates, and examples alongside
  instructions — keeping everything a role needs in one place.

- **Instruction file strategy:** `AGENTS.md` (Linux Foundation open standard, supported by
  Codex, Cursor, Copilot, Gemini CLI, and others) holds repo-wide CLD rules. Platform-specific
  files stay minimal:
  - `CLAUDE.md` → Claude-specific overrides only; skills carry the role definitions
  - `.github/agents/*.agent.md` → thin wrappers referencing skills (Copilot reads `.agents/skills/` directly, so these are optional)
  - Codex reads `AGENTS.md` and `.agents/skills/` natively — no extra files needed

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
- `docs/decisions/` — lightweight; most decisions live in PRs, this is for cross-cutting decisions only
- `docs/experiments/` — outputs from exploration mode
- `docs/cld/boundaries.md` — what CLD does not claim to solve

  0.3. Write minimal document templates (1 each):

- **Initiative** (`INIT-*.md`)

- **Hypothesis** (`HYP-*.md`) — must include:
  - **Uncertainties (embedded, ranked):** at least 2 unknowns that could each independently
    invalidate the approach, ranked by risk × effort-to-test. Use stable IDs (e.g. `UNC-ADO-001`)
    so they can be extracted later without refactoring. Each uncertainty: description, risk
    level, effort to test, status (Untested / In Progress / Reduced / Dismissed / Fatal).
  - **Selected uncertainty:** the single uncertainty this hypothesis targets — the one
    with the most risk reduced per effort. One hypothesis → one uncertainty.
  - **Falsification signal:** what result would make this hypothesis unlikely or wrong?
  - **Why a positive result is not trivial:** prevents "user clicked = validated"
  - **Alternative hypothesis:** what else could explain the problem? Why do we prefer the current hypothesis?
  - **Time to evidence:** how quickly can we get signal? (hours / days / weeks). Prefer worse test sooner over perfect test later.

- **Story** (`ST-*.md`) — two modes:
  - **Probe story** (during discovery): evidence-first, not feature-first. Goal is to
    reduce a specific uncertainty, not to ship a feature. References a UNC-ID.
    Example: "Fetch 10 ADO items via API → inspect payload for required fields."
  - **Delivery story** (after discovery exit): expected behavior = the test spec. Only
    allowed after the discovery exit contract is met. Includes chosen test level and
    decision type (reversible / irreversible).

- **Evidence** (`EVID-*.md`) — test result = expected vs actual = decision.
  Must update the uncertainty status in the originating HYP after each probe.

  **Design note: embedded UNC → separate UNC-\* extraction triggers.**
  Uncertainties start embedded in HYP-\* to minimize friction and maximize adoption.
  Extract to standalone `docs/uncertainties/UNC-*.md` files only when one of these
  triggers fires:
  - **Reuse emerges:** the same uncertainty appears across multiple HYPs (e.g. API
    rate limits, identity model, permissions).
  - **Tracking becomes painful:** you ask "what uncertainties are still open?" and
    can't answer without reading every HYP.
  - **Scale increases:** multiple people or agents work in parallel and need shared
    uncertainty state.
    Because UNC-IDs are stable (e.g. `UNC-ADO-001`), extraction preserves all existing
    references — no refactoring required.

    0.4. Draft CLD role behaviors (input for Phase 1 skill authoring):

  Write down the key constraints and questions each role must enforce — not yet as
  SKILL.md files (that's Phase 1), but as working notes that drive skill content:

- **Discovery** — purpose, inputs, outputs, constraints.
  - **Discovery micro-loop** (mandatory before any HYP-\* is created):
    1. Produce uncertainty inventory (≥2 items that could each independently invalidate the approach, ranked by risk × effort-to-test).
    2. Select the highest-value uncertainty (most risk reduced per effort).
    3. Define the smallest evidence probe (not a feature — a question with a test).
    4. Execute probe → produce EVID-\*.
    5. Update uncertainty list (status: Reduced / Invalidated / still Untested).
    6. Repeat or exit to hypothesis when sufficiently reduced.
  - Must not deliver implementation suggestions before at least one alternative explanation is formulated.
  - Must ask: "What would falsify this hypothesis?"
  - Must propose time-to-evidence target.
  - **Must refuse:** full solution design, multi-slice planning, architecture proposals.
  - **Anti-pattern detection — must flag if:**
    - Hypothesis contains system-level words ("sync service", "platform", etc.) without a concrete entity
    - No concrete API, entity, or data shape mentioned
    - No sample size defined in the probe (e.g. "10 items", "5 requests")
    - Probe requires writing production code

- **Delivery** — implements against the falsification signal.
  - Must not write code before the claim and its falsification signal are named.
  - Test level chosen by what validates the behavior, not by convention.

- **Review** — checks whether the test actually falsifies the hypothesis:
  - Could this result happen if the hypothesis is wrong?
  - What's the most likely alternative explanation for the result?
  - What signal is still missing?
  - **Anti-gaming heuristics:** flag if hypothesis phrasing ≈ implementation phrasing,
    if test only validates happy path, if alternative hypothesis is weak/strawman (<20 chars
    or suspiciously similar to primary), if no plausible falsification is defined.
  - **Hypothesis-evidence type check:** flag when evidence type doesn't match hypothesis type
    (e.g. unit test validating a value hypothesis, usage metric validating a technical hypothesis).
    Reference typology: behavioral → observation/usage; value → outcome/retention;
    technical → tests; operational → metrics.

    0.5. Write one real example through the full chain:

- Pick a small, realistic feature (e.g. a CLI tool, a small API endpoint).
- Create INIT → HYP → ST → EVID files manually.
- This validates the schema before any automation.

### Exit criteria

- One complete example chain exists and feels lightweight enough to use.
- Uncertainty inventory embedded in HYP feels natural, not bureaucratic.
- Probe stories feel distinct from delivery stories — lighter, question-focused.
- Falsification signal and alternative hypothesis feel natural, not bureaucratic.

---

## Phase 1 — Cross-Platform Skills (Week 2)

**Goal:** Create `.agents/skills/` as the single canonical location for CLD role definitions. Verify all three platforms pick them up and enforce the constraints.

### Steps

1.1. **`AGENTS.md` at repo root** — lightweight behavioral contract for all platforms:

- Repo-wide rules (no code without hypothesis, no scope invention, etc.)
- Core principle: every step reduces uncertainty.
- Falsification-first: every hypothesis must define what would disprove it.
  Alternative hypothesis required. Time-to-evidence target required.
- Agent forcing functions (brief; full role definitions live in skills):
  - Discovery: must not suggest implementation before alternative explanation exists.
  - Delivery: must not write code before claim + falsification signal are named.
  - Review: must not approve if test only confirms implementation, not hypothesis.
- Points to `.agents/skills/` for full role definitions.

  1.2. **Create `.agents/skills/`** — three CLD skill folders, each with a `SKILL.md`:

- `cld-discovery/SKILL.md` — role purpose, inputs/outputs, constraints, gate-check
  references, must-ask questions (falsification signal, alternative hypothesis,
  time-to-evidence). **Discovery micro-loop enforcement:**
  - Mandatory outputs: uncertainty inventory (≥2 independently fatal items), ranked uncertainties,
    selected uncertainty, smallest probe (not feature).
  - Mandatory constraints: must refuse full solution design, multi-slice planning,
    architecture proposals.
  - Anti-pattern detection: flag hypothesis with system-level words but no concrete
    entity, no sample size in probe, probe that requires production code.
  - Trigger: vague request, new initiative, hypothesis not written, **or HYP-\*
    requested but no uncertainty inventory exists** (block until inventory is done).
- `cld-delivery/SKILL.md` — story-scoped delivery, implements against the falsification
  signal, test-first, no scope invention. Trigger: approved ST-\* with HYP-\* link exists.
- `cld-review/SKILL.md` — traceability check, anti-gaming heuristics, validates test
  level matches the claim. Trigger: PR open with linked ST-\*, HYP-\*, EVID-\*.

  Each skill bundles: role instructions, references to gate-check scripts, template paths,
  and a short example. This replaces `docs/cld/agents/` as the canonical role source.

  1.3. **GitHub Copilot:**

- Reads `.agents/skills/` natively — no extra files strictly required.
- Optional thin wrappers in `.github/agents/*.agent.md` for trigger descriptions or
  Copilot-specific UI labeling (reference skills; do not duplicate content).

  1.4. **Claude Code:**

- Reads `.agents/skills/` natively.
- `CLAUDE.md` holds Claude-specific overrides only (subdirectory scoping, slash command
  mappings). Role definitions stay in skills, not in `CLAUDE.md`.

  1.5. **OpenAI Codex:**

- Reads `AGENTS.md` and `.agents/skills/` natively — no extra files needed.
- Sandbox policy: `workspace-write`, approval `on-request`, network off by default.

  1.6. **Cross-platform test** against the Phase 0 example:

- Feed the same initiative to discovery role on each platform.
- Feed the same story to delivery role on each platform.
- Compare: does each platform respect the constraints?
  - Does discovery refuse to code?
  - Does discovery produce a falsification signal and alternative hypothesis?
  - Does delivery refuse to invent scope?
  - Does review catch gaps, including anti-gaming flags?
- Document behavioral differences in `docs/cld/platform-notes.md`.

### Exit criteria

- `.agents/skills/` contains all three CLD role skills; no role content duplicated in platform-specific files.
- Each agent role behaves noticeably different from a generic coding agent — on every platform, driven by the same skill source.
- Discovery refuses to code. Delivery refuses to invent scope. Review catches gaps.
- **Discovery produces uncertainty inventory before any hypothesis — on every platform.**
- **Discovery blocks when asked for HYP without prior uncertainty reduction.**
- Forcing functions are observable: agents actually block on missing falsification/alternatives.
- Platform-specific quirks are documented in `docs/cld/platform-notes.md`.

---

## Phase 2 — GitHub Templates & PR Contract (Week 2–3)

**Goal:** Structural forcing functions via GitHub native features.

### Steps

2.1. Create issue template (`.github/ISSUE_TEMPLATE/cld-issue.md`):

- Problem statement, who experiences it, evidence, assumptions, success signal.

  2.2. Create exploration issue template (`.github/ISSUE_TEMPLATE/cld-exploration.md`):

- Goal: generate hypotheses, not validate them.
- No hypothesis required upfront.
- Outputs: observations, candidate hypotheses.
- Time-boxed: must define when exploration ends and what "enough to hypothesize" looks like.
- This prevents fake precision early and keeps CLD honest when understanding is still forming.
- **Mandatory path to HYP:** exploration (with uncertainty inventory) is the required
  entry point for any non-fast-lane work. You cannot create a HYP-\* without having
  produced and ranked uncertainties first. The exploration issue is the natural home
  for that pre-hypothesis work.

  2.3. **Discovery exit contract** (hard gate — checklist in PR or issue):

  Canonical checklist: `.agents/skills/cld-discovery/SKILL.md` → **Discovery Exit Contract**.

  This contract becomes a CI-checkable gate: PRs that introduce delivery stories
  (ST-\* without `Type: Probe`) must reference a HYP-\* where at least one
  uncertainty status is "Reduced" with a linked EVID.

  2.4. Create PR template (`.github/pull_request_template.md`):

- Linked references (initiative, hypothesis, story).
- **Gate questions** (not just fields to fill):
  - What assumption is being acted on?
  - What would falsify it?
  - What is the cheapest acceptable signal, and why is it strong enough to proceed?
  - What remains uncertain?
- **Decision record** (embedded in PR, not a separate artifact):
  - What are we choosing to believe now?
  - Confidence: Low / Medium / High
  - Reversal trigger: what would make us revisit this?
- Post-release observation plan.

  2.5. Define fast-lane criteria:

- **Decision anchor: reversibility × blast radius.**
  Not every change deserves the full closed loop. The triage rule:
  - _Easy to undo + small blast radius_ → fast-lane (evolutionary track).
    - fast-lane — expected effect, test evidence, rollback thought. Skip full discovery.
    - Build it, ship it, measure whether it earns its keep.
  - _Hard to undo + large blast radius_ → full CLD loop.
    - full CLD — falsification signal, alternative hypothesis, confidence level, reversal trigger.
    - Data models, public APIs, cross-feature integrations, security boundaries.
  - The default is fast-lane. CLD discipline is the exception that earns its
    way in — justified by the cost of getting it wrong, not by process dogma.
- Which change types (bug fixes, refactors, deps) typically qualify for fast-lane?
- Even fast-lane requires: expected effect, test evidence, rollback thought. e.g. "what could go wrong and how would we know?"

### Exit criteria

- Every new issue and PR is guided by the template.
- Exploration mode exists, is the mandatory path to HYP, and produces hypotheses, not code.
- Discovery exit contract is clear and CI-checkable.
- Fast-lane exists, is reversibility-based, and doesn't feel like cheating.

---

## Phase 3 — Gate Checks: Pre-commit + CI (Week 3–4)

**Goal:** Two-layer enforcement — fast local feedback via pre-commit hooks,
non-bypassable gates via CI.

### Why two layers

Pre-commit hooks catch mistakes before you push (fast, immediate feedback).
CI catches everything else server-side and cannot be skipped
(`git commit --no-verify` bypasses hooks, nothing bypasses CI).

### Steps

3.1. **Pre-commit hooks** (fast local checks via `scripts/`):

- `scripts/check-pr-links.sh` — commit message or PR body references at least one `ST-*`.
- `scripts/check-pr-template.sh` — required sections not empty/placeholder.
- Install via a simple setup script or tool like `pre-commit` / `husky`.

  3.2. **CI gate checks — hard gates** (structural, non-bypassable):

- `scripts/check-story-links.sh` — referenced story file must contain a `HYP-*` link.
- `scripts/check-uncertainties.sh` — referenced `HYP-*` must have a `## Uncertainties`
  section with at least 2 UNC-\* rows, and a non-empty `## Selected Uncertainty` section.
- `scripts/check-falsification.sh` — referenced `HYP-*` must have a non-empty
  falsification signal and alternative hypothesis section.
- `scripts/check-test-evidence.sh` — PR must include at least one test change that
  maps to the hypothesis or story behavior (or explicit justification for why no
  new test is needed). Validates presence, not coverage metrics.
- `scripts/check-decision-fields.sh` — for PRs tagged irreversible/high-impact:
  confidence level and reversal trigger must be present.
- `scripts/check-discovery-exit.sh` — for PRs introducing delivery stories: verify
  at least one UNC status = "Reduced" with a linked EVID-\*.
- Cross-file validation that pre-commit hooks cannot do locally.

  3.3. **CI soft checks — anti-gaming flags** (warnings, not blockers):

- Hypothesis phrasing similarity to implementation code (basic string/token overlap).
- Alternative hypothesis suspiciously short or similar to primary.
- Trivial falsification signals (too generic, e.g. "it doesn't work").
- **Hypothesis too broad** — keyword heuristic: contains "sync", "service", "platform",
  "system" without a concrete entity or API named.
- **No sample size in probe** — probe story lacks a concrete quantity.
- **Probe looks like implementation** — probe story references production code paths
  or introduces non-disposable artifacts.
- These produce warnings in the PR, not failures. Review agent or human reviewer acts on them.

  3.4. Create `.github/workflows/cld-gate-check.yml` running the full script suite.

  3.5. Run against 3–5 real PRs to calibrate strictness.

- Too strict → teams route around it.
- Too loose → no behavior change.
- Too many false positives on anti-gaming flags → noise that gets ignored.

### Exit criteria

- CI fails on PRs that skip the chain. Fast-lane PRs pass with lighter checks.
- Anti-gaming flags fire on obviously weak hypotheses but don't block work.

---

## Phase 4 — Pilot with Real Work (Week 4–6)

**Goal:** Build a small but real feature using CLD. Compare agent behavior across platforms.
Validate that the overhead costs less than the rework it prevents.

### Steps

4.1. Define 3–5 feature slices for the fresh repo (e.g. a small CLI tool, REST API, or utility library).

4.2. Run each slice through the full CLD workflow:

- Issue → Exploration (uncertainty inventory) → Discovery micro-loop (probe → evidence → update) → Hypothesis → Story → Implementation → PR (with decision record) → Review → Evidence

  4.3. Rotate agent platforms across slices:

- Slice A: GitHub Copilot agents
- Slice B: Claude Code
- Slice C: Codex
- This produces comparable data on how each platform responds to the same constraints.

  4.4. Track friction points per platform:

- Where do agents try to skip steps?
- Which platform respects forcing functions best out of the box?
- Do agents generate genuine falsification signals or compliant filler?
- Do agents produce real alternative hypotheses or strawmen?
- **Do agents produce genuine uncertainty inventories or fill-in-the-blank lists?**
- **Do agents respect the micro-loop (probe → evidence → update) or try to skip to delivery?**
- Which templates feel too heavy?
- Which CI checks produce false positives?
- Do anti-gaming flags catch real issues or just noise?

  4.5. **Synthesis checkpoints** (lightweight):

  Every 3–5 EVID produced during a slice, write a short synthesis:
  - What did we learn?
  - What constraints emerged?
  - What system shape is now obvious that wasn't before?

  This prevents discovery from fragmenting into disconnected probes.

  4.6. **Validate the core bet:**

- Did falsification signals catch anything that "smallest possible test" alone would have missed?
- Did alternative hypotheses surface real alternatives or just waste time?
- Did decision records with reversal triggers lead to any actual reversals?
- **Did the uncertainty inventory change the sequencing of work?**
- **Did probe stories prevent premature implementation?**
- **Did the discovery exit contract catch slices that would have left discovery too early?**
- At least one case where the closed loop prevented building the wrong thing.

  4.7. Conduct a retrospective specifically on CLD:

- Did it change what got built?
- Did it surface assumptions that would have been missed?
- What's the actual overhead vs perceived overhead?
- Which platform is the best fit for which role?
- **Which hardening additions (falsification, alternatives, decision records, uncertainty inventory, discovery micro-loop) earned their keep?**

  4.8. Refine templates, agent instructions, and CI checks based on findings.

### Exit criteria

- At least one case where the closed loop prevented building the wrong thing.
- **At least one case where the discovery micro-loop changed sequencing vs. what would have been built without it.**
- Platform comparison documented in `docs/cld/platform-notes.md`.
- CLD does not feel like pure overhead.
- **Evidence on whether hardening additions (falsification, alternatives, anti-gaming, uncertainty inventory, discovery micro-loop) are net positive.**

---

## Phase 5 — Agent Evals (Week 6–8)

**Goal:** Systematically measure whether agents behave as intended.

### Steps

5.1. Create `prompts/evals/` with test cases for each agent role:

- Discovery: does it challenge vague requests? Does it produce alternatives?
  Does it propose a falsification signal for each hypothesis?
  Does it resist jumping to implementation before alternatives are explored?
  **Does it produce a ranked uncertainty inventory (≥2 independently fatal items) before any hypothesis?**
  **Does it block when asked for HYP without prior uncertainty reduction?**
  **Does it flag anti-patterns (system-level hypothesis without entity, no sample size, probe = production code)?**
  **Does it run the micro-loop (probe → evidence → update) rather than jumping straight to HYP?**
- Delivery: does it stay within scope? Does it write the test that matches the
  falsification signal before production code? Does it choose the right test level?
  **Does it reject delivery stories when the discovery exit contract is not met?**
- Review: does it detect missing traceability? Does it flag coverage theater?
  Does it catch gaming patterns (hypothesis ≈ implementation, strawman alternatives,
  trivial falsification, evidence-type mismatch)?
  **Does it flag missing or incomplete uncertainty inventories?**
  **Does it check that the selected uncertainty is the highest-value one?**

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

> **AI makes building cheap but doesn't make being wrong cheaper.** Spec-driven
> frameworks structure intent. Agile frameworks structure work. CLD structures
> belief under uncertainty.
>
> CLD is a repo-native system of structured probes and enforceable gates —
> tests, checks, observations, reversal triggers — that govern what the system
> is allowed to become.
>
> The repo carries not just behavior but decision history and discarded paths.
> Failed hypotheses persist so teams don't re-explore the same dead ends.
> Superseded learnings can be archived — but never silently discarded.
>
> Every gate asks one question: did you reduce enough uncertainty to continue?

---

# Appendix: Hardening Changelog (v1 → v2)

Changes based on devil's advocate analysis and targeted hardening:

| Change                                                                    | Addresses                                                       | Impact                        |
| ------------------------------------------------------------------------- | --------------------------------------------------------------- | ----------------------------- |
| Falsification signal replaces "smallest possible test" as primary framing | Validation illusion (#2), CI quality gap (#5)                   | Tier 1                        |
| Alternative hypothesis required in HYP-\*                                 | Confirmation bias (#2), agent gaming (#8)                       | Tier 1                        |
| Decision record with reversal trigger embedded in PR template             | Process theater (#4), traceability ≠ truth (#5)                 | Tier 1                        |
| Anti-gaming heuristics (review agent + CI soft checks)                    | Agent gaming (#8)                                               | Tier 1                        |
| Hard/soft gate distinction                                                | CI can't enforce quality (#5), Goodhart's Law (#4)              | Design principle              |
| Exploration mode (issue template)                                         | Premature framing (#9)                                          | Tier 2                        |
| Reversibility-based fast-lane criteria                                    | Slowing wrong parts (#6)                                        | Tier 2                        |
| Hypothesis-evidence type checking (review heuristic)                      | Validation illusion (#2)                                        | Tier 2 (promote if validated) |
| Time-to-evidence constraint                                               | Analysis paralysis                                              | Tier 2                        |
| Known boundaries documented                                               | Wrong failure mode (#1), tacit knowledge (#3), incentives (#10) | Scope clarity                 |
| Reframe: decision gate system, not artifact flow                          | Process theater (#4), core identity                             | Foundational                  |

# Appendix: Hardening Changelog (v2 → v3)

Changes based on discovery gap analysis — CLD was strong on gates but weak on
navigation inside discovery. People rushed to hypothesis without reducing uncertainty first.

| Change                                                                               | Addresses                                                               | Impact           |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- | ---------------- |
| Embedded uncertainty inventory in HYP-\* (ranked, with extractable IDs)              | Premature hypothesis, weak alternatives, rushing to implementation      | Tier 1           |
| Discovery micro-loop (uncertainty → probe → evidence → update → repeat/exit)         | Underspecified discovery, no sequencing of learning                     | Tier 1           |
| Discovery exit contract (hard gate checklist)                                        | People leaving discovery too early, no minimum evidence bar             | Tier 1           |
| Probe stories (ST-\* Type: Probe) distinct from delivery stories                     | Probes disguised as features, evidence-first vs feature-first confusion | Tier 1           |
| Exploration as mandatory path to HYP (not optional)                                  | Bypassing uncertainty reduction, jumping straight to solution           | Tier 1           |
| Anti-pattern detection in discovery skill (system-level words, no sample size, etc.) | Agent gaming, compliant nonsense in uncertainty inventories             | Tier 2           |
| Synthesis checkpoints (every 3–5 EVID)                                               | Discovery fragmentation, disconnected probes                            | Tier 2           |
| Core principle refined: "highest-value uncertainty next" (not just "reduce any")     | Random exploration, over-analysis                                       | Design principle |
| CI gate: `## Uncertainties` section required in HYP-\*                               | Skipping uncertainty inventory                                          | Enforcement      |
| CI gate: discovery exit contract check for delivery stories                          | Entering delivery without evidence                                      | Enforcement      |
| Soft gate: hypothesis-too-broad keyword heuristic                                    | System-level hypotheses without concrete entities                       | Enforcement      |
| Design: embedded UNC with extractable IDs (not separate artifact yet)                | Adoption friction vs structural rigor tradeoff                          | Migration-safe   |

# Appendix: Hardening Changelog (v3 → v4)

Changes based on identity sharpening — CLD was described as a process framework but
is actually a repo-native hypothesis control system. Language and framing updated to
match.

| Change                                                                              | Addresses                                                         | Impact           |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------- | ---------------- |
| USP reframed: "structures belief under uncertainty" (vs intent, vs work)            | Weak differentiation from BMAD, spec-driven, Agile                | Foundational     |
| Identity: "repo-native control system", not "workflow framework"                    | Underselling CLD as process documentation                         | Foundational     |
| "Probe" as unifying concept (verification + validation probes)                      | Collapsing everything into "tests" → TDD-with-extra-steps risk    | Tier 1           |
| Three enforcement layers: structural, executable, interpretive                      | Only structural gates described; executable/interpretive implicit | Tier 1           |
| "test ≠ evidence ≠ validation" made explicit                                        | Validation illusion — passing test conflated with confirmed claim | Tier 1           |
| Dead ends as first-class artifacts (persist by default, archive with justification) | Success-biased storytelling, re-exploring same dead ends          | Design principle |
| "System = behavior + decision history + discarded paths"                            | Repo seen as just code, not as decision record                    | Design principle |

---

# References

- **Author:** Florian Mücke — original concept, framework design, and project plan.
- The "harness" metaphor that informed early thinking on this project:
  Henrique Bastos, [Making Sense of Harness Engineering](https://www.linkedin.com/pulse/making-sense-harness-engineering-henrique-bastos-ezotf/)
- Kent Beck, _Extreme Programming Explained_ — the intellectual foundation for
  why feedback loops and forcing functions matter more than process artifacts.
