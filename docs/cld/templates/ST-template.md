# ST-YYYY-NNN: [Title]

Initiative: INIT-YYYY-NNN
Hypothesis: HYP-YYYY-NNN

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

- [ ] **Reversible** — low cost to undo; fast-lane CI checks apply
- [ ] **Irreversible / high-impact** — API contract, data model, public interface, or user-facing change; full CLD required: confidence level and reversal trigger must appear in the PR

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
