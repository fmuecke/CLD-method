# CLD — Known Boundaries

CLD explicitly targets **assumption-driven failure** in agent-assisted development.
It is a system of skeptical forcing functions, not a general software quality framework.

## What CLD Does Not Claim to Solve

### Integration Complexity / Operational Brittleness

Distributed systems fail for reasons that have nothing to do with wrong assumptions at the
problem-framing stage — network partitions, dependency drift, load characteristics, cascading
failures. CLD does not address this. Different failure mode, different tools (observability,
chaos engineering, contract testing).

### Organizational Incentives

CLD is repo-level, not org-change. If incentives reward shipping fast over being right,
people will route around any process — including this one. A team that is measured on
story points closed per sprint will produce compliant-looking HYP documents and hollow
evidence records. CLD cannot fix that. It can make the gaming visible, but only if someone
is watching.

### Tacit Knowledge

Architecture intuition, UX feel, "this smells wrong" — these don't compress into
HYP → ST → TEST → EVIDENCE chains. CLD handles the formalizable subset of uncertainty.
Senior judgment remains the last gate, especially for irreversible decisions. The review
agent flags gaps; it does not replace the experienced human who knows what the flags mean.

### Time-to-Market Pressure

CLD adds friction. The bet is that this friction costs less than the rework it prevents.
Phase 4 must validate this bet with actual data. Until then, the cost of CLD is real
and the benefit is theoretical.

## What Does Not Need a Hypothesis

Triage by reversibility × blast radius. The default is fast-lane — full CLD earns its way in when a wrong assumption would be expensive to undo or has wide impact.

| | Small blast radius | Large blast radius |
|---|---|---|
| **Easy to undo** | Fast-lane | Fast-lane + extra care |
| **Hard to undo** | Fast-lane + extra care | Full CLD |

Operational changes where verification is deterministic don't need a falsification signal — the test suite is already the falsification mechanism. The right question is: is there genuine uncertainty about an assumption, or is the risk simply breakage?

- **Needs full CLD:** new behavior, user-facing flows, architectural choices with competing options — wrong assumption → wrong thing built
- **Needs only fast-lane:** version bumps, bug fixes with clear root cause, config changes, refactors with no behavior change — wrong execution → tests catch it

Example: "Update component X to version 1.2" is a fast-lane case. The only real question is whether it breaks something, and CI answers that deterministically. There is no hypothesis to write. Forcing one produces compliance paperwork: "falsification: tests fail" — which is trivially true of everything.

If the update _is_ motivated by an uncertain claim — "X 1.2's new caching should reduce our p95 latency" — that claim is worth a hypothesis. But the claim is the motivation, not the update itself.

## Revisit Schedule

These boundaries should be reviewed after the Phase 4 pilot with evidence on:

- Which types of failures CLD actually prevented
- Which types it missed entirely
- Whether the overhead-to-benefit ratio holds at real team scale
