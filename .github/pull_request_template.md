<!--
  CLD Pull Request
  Select one track and delete the other.
-->

## Track

- [ ] **Full CLD** — new behavior, architectural choice, or irreversible/high-impact change
- [ ] **Fast-lane** — reversible/low-risk change (dependency update, bug fix, refactor, config)

---

## Full CLD

### Linked Documents

- Initiative: INIT-YYYY-NNN
- Hypothesis: HYP-YYYY-NNN
- Story: ST-YYYY-NNN
- Evidence: EVID-YYYY-NNN

### Gate Questions

**What assumption is being acted on?**

**What would falsify it?**

**What is the cheapest acceptable signal, and why is it strong enough to proceed?**

**What remains uncertain after this change?**

### Decision Record

**What are we choosing to believe now?**

Confidence: Low / Medium / High

**Reversal trigger:** what new evidence would make us revisit this decision?

### Post-release Observation Plan

_What signal will we monitor in production, and for how long?_

---

## Fast-lane

**Change type:** Bug fix / Refactor / Dependency update / Config / Other

**Expected effect:**

**Test evidence:**

**Rollback:** how to reverse if something breaks.

<!--
  Fast-lane applies to reversible, low-risk changes where the verification
  is deterministic — the test suite is the falsification mechanism.
  If the change is motivated by an uncertain claim ("this will improve X"),
  that claim deserves a hypothesis. Use Full CLD for that.
-->
