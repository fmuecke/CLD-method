> Q9: Another another thing that I think that we are going to need is some kind of hypothesis builder because Currently, we are just don't know how to write good hypotheses. And we're skipping it So maybe this is a good idea for a side project. Some just some prompt or little helper that Helps with guided questions to formulate useful and testable hypotheses.

A:
That's not a side project — that's a core enabler. If people can't write hypotheses, the entire CLD loop is dead on arrival. The templates will sit empty.

And you're describing exactly the problem from Q3: people skip hypotheses because holding uncertainty is cognitively expensive. A guided builder reduces that cost.

The simplest version is just a structured question chain:

1. **What do you believe is true?** (the claim)
2. **Who told you / what made you think this?** (the source — observation, data, opinion, guess?)
3. **What would change if you're right?** (the outcome — if nothing changes, it's not worth testing)
4. **What would prove you wrong?** (falsification — if nothing could, it's not a hypothesis)
5. **What's the cheapest way to find out?** (smallest possible test)

If someone can answer those five questions, they have a testable hypothesis. If they can't answer #4, they have an assumption disguised as a fact — which is exactly what you want to catch.

This could live in three places:

- **As a discovery agent capability** — baked into the agent prompt so it walks you through this whenever you start from a vague idea
- **As a standalone tool** — a simple interactive prompt you can use in your existing Kanban flow, no repo needed, works today
- **As a template preamble** — the five questions printed right in the `HYP-*.md` template so they're unavoidable

Want me to build a quick interactive prototype of the hypothesis builder? I could make it as a React artifact you can try right now — just paste in a vague idea and it walks you through the five questions.

--> start with the template preamble

Let me look at the Q6 document for the original hypothesis template to build on:Good — the original schema has the right sections but doesn't guide you through the thinking. Let me also grab the other templates for consistency:Now let me create the full template set — hypothesis with the guided preamble, plus the other three updated with CLD principles:Four templates, all aligned. The key design choices:

**Hypothesis template** — the guided preamble walks you through the five questions as an HTML comment block. It's visible when editing, invisible when rendered. The hardest question (#4 "what would prove you wrong?") is explicitly flagged as the most important. The "Smallest Possible Test" section forces you to state the method AND what constitutes confirmation vs rejection — no vague "we'll see."

**Initiative template** — added a trap for solution-disguised-as-problem: the comment explicitly says "if you're writing 'build X', stop and rephrase as the pain."

**Story template** — replaced the old "test levels" checklist (unit/integration/E2E/production) with a single "Smallest Possible Test" section that asks you to pick ONE level and justify why it's sufficient. This kills the instinct to fill in all four levels for completeness.

**Evidence template** — every record must end with a next step. No evidence file gets closed with "we'll think about it."

These are Phase 0 deliverables — ready to use in the fresh repo. The interactive hypothesis builder (standalone tool version) would be a natural follow-on once you've used these manually and know which questions people actually struggle with.
