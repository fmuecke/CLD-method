# CLD TODO

Process improvements identified during the Phase 4 pilot.

## Discovery

- **Hypothesis ordering:** After hypotheses are written, explicitly check their logical dependency order — what must be true before the next hypothesis can even be tested? The order in which hypotheses are listed in the INIT should reflect test sequence, not the order they were discovered. Consider adding a "Depends on" field to the HYP template, or a dependency check step to the Discovery agent's handoff checklist.
- **Assumption brainstorming/triggering:** What do we need to know about the system we want to work with? What technical contraints are there? What must be true for that to work? What is the smallest thing to begin with to really move this forward?
  --> The pattern is: agent generates breadth, human prunes with experience. That's the efficient split.
Which means the forcing function isn't "agent must brainstorm alone" — it's "agent must present assumption map before hypothesizing, human confirms or redirects." The Discovery agent's instruction would say something like: "Before producing any HYP, list the technical constraints, system boundaries, and preconditions you've identified. Wait for confirmation before proceeding."
That keeps the loop tight: agent does the legwork, you spend 30 seconds saying "yes, and you missed X" instead of 10 minutes generating the list yourself.
- **Source-of-truth direction check:** When a story involves two systems, the Discovery or Review step should explicitly ask: for each data field, which system owns it? Write operations in the wrong direction (e.g. writing ADO data into BM when BM is source of truth) are a category of scope error that should be caught before delivery, not after.