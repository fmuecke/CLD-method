# ST-YYYY-NNN: [Title]

Initiative: INIT-YYYY-NNN
Hypothesis: HYP-YYYY-NNN

## Story Type

<!-- Pick one. This determines which sections below are required.

     PROBE — used during discovery to reduce a specific uncertainty.
       Goal is evidence, not a shipped feature. Output is disposable.
       Required: Uncertainty Target, Probe Action, Expected Signal.
       Skip: Scope Boundary, Constraints, Decision Type.

     DELIVERY — used after discovery exit to implement a validated slice.
       Only allowed when the discovery exit contract is met (at least one
       UNC status = "Reduced" with linked EVID in the originating HYP).
       Required: all sections below. -->

- [ ] **Probe** — evidence-first; reduce a specific uncertainty
- [ ] **Delivery** — feature-first; implement validated behavior

---

<!-- ============================================================
     PROBE STORY — fill this section if Story Type = Probe
     ============================================================ -->

## Uncertainty Target

<!-- Which uncertainty does this probe address? Reference the UNC-ID from HYP. -->

UNC-ID: UNC-XXX-NNN
From: HYP-YYYY-NNN

## Probe Action

<!-- What is the smallest action that gives signal about this uncertainty?
     This is NOT a feature. It's a question with a test.
     Must include a concrete sample size. -->

_Example: Fetch 10 ADO work items via REST API and inspect payload for fields X, Y, Z._

- Action:
- Sample size:
- Tools / access required:

## Expected Signal

<!-- What result answers the uncertainty? State both the confirming and
     falsifying outcomes explicitly. -->

- Reduces uncertainty if:
- Falsifies if:

## Probe Evidence

- EVID-YYYY-NNN: _(link after probe execution — ensure the EVID header references this story: ST-YYYY-NNN)_

---

<!-- ============================================================
     DELIVERY STORY — fill this section if Story Type = Delivery
     ============================================================ -->

## Slice

_What thin vertical slice is implemented? This should be the smallest piece of work that reduces uncertainty about the hypothesis._

## Expected Behavior

_This IS the test spec. State as concrete, executable examples. Each must be verifiable._

- Given [context]...
- When [action]...
- Then [outcome]...

## Smallest Possible Test

_What is the cheapest test that validates this behavior? Choose the test level by what proves the behavior, not by convention._

- Test type: Unit / Integration / E2E / Manual observation / Log query / Other
- Why this level is sufficient:

## Decision Type

Triage by reversibility × blast radius (default: fast-lane):

- [ ] **Fast-lane** — easy to undo or small blast radius; CI checks are the falsification mechanism
- [ ] **Full CLD** — hard to undo **and** large blast radius (API contract, data model, public interface, security boundary); confidence level and reversal trigger must appear in the PR

## Scope Boundary

**In scope:**

- _(list explicitly what this story covers)_

**Out of scope:**

- _(list explicitly what is deferred — prevents scope creep)_

## Constraints

_Security, performance, UX, compatibility — anything the implementation must respect. Optional; omit if none._

## Evidence Required Before Merge

- [ ] Smallest possible test passes
- [ ] Expected behavior examples covered
- [ ] Production observation plan defined (for user-facing changes)

## Evidence

- EVID-YYYY-NNN: _(link after delivery)_
