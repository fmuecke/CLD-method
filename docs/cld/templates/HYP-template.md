# HYP-YYYY-NNN: [Assumption being tested]

Status: Open | In Test | Confirmed | Rejected
Initiative: INIT-YYYY-NNN

<!--
  HOW TO WRITE THIS HYPOTHESIS

  Answer these questions in order. If you get stuck on any of them,
  that's useful information — it means the hypothesis isn't ready yet.

  START WITH UNCERTAINTIES — not with what you believe.
  Before you can state a hypothesis, you need to know what you don't know.
  List at least 2 unknowns that could each independently kill this idea, rank
  them, and pick the one that gives the most learning per effort. That uncertainty
  becomes the target of this hypothesis.

  If you can't list 2 uncertainties that could each independently kill the idea,
  you don't understand the problem well enough to hypothesize. Go back to exploration.

  1. WHAT DON'T WE KNOW THAT COULD KILL THIS?
     List unknowns — technical, behavioral, data-related. Each must be capable
     of independently invalidating the approach if unresolved. Rank by
     risk × effort-to-test. Use stable IDs (UNC-XXX-001) so they
     can be referenced from evidence and extracted later if needed.

  2. WHICH UNCERTAINTY ARE WE TARGETING?
     Pick the one with the most risk reduced per effort. Not the most
     interesting — the most dangerous AND cheapest to test.

  3. WHAT DO WE BELIEVE IS TRUE?
     Write it as a concrete, falsifiable claim scoped to the selected
     uncertainty. Not "improve onboarding" but "new users abandon the
     signup form because it requires a credit card." Not "we can sync
     both systems" but "we can retrieve the required fields from ADO
     for item type X."

  4. WHY DO WE THINK THIS?
     What's your source — observed data, user feedback, gut feeling, someone
     said so? Be honest. "We assume" is a valid answer and better than
     dressing up a guess as a fact.

  5. WHAT WOULD CHANGE IF WE'RE RIGHT?
     If this hypothesis is confirmed, what observable outcome improves?
     If nothing changes, it's not worth testing.

  6. WHAT WOULD FALSIFY THIS?
     This is the hardest and most important question.
     If nothing could prove you wrong, you don't have a hypothesis —
     you have an opinion. Rephrase until you can answer this.
     Also ask: why is a positive result not trivial? "User clicked the button"
     is not confirmation. What would a skeptic say?

  7. WHAT ELSE COULD EXPLAIN THE PROBLEM?
     State the alternative hypothesis — what would a skeptic propose instead?
     A real alternative, not a strawman.

  8. WHAT'S THE CHEAPEST WAY TO FIND OUT?
     State the test method AND what result constitutes confirmation vs rejection.
     Then ask: how quickly can we get this signal? Prefer a worse test sooner
     over a perfect test later.
-->

## Uncertainties

<!-- List at least 2 unknowns that could each independently invalidate the approach.
     Rank by risk × effort-to-test.
     Use stable IDs (e.g. UNC-ADO-001) — these can be extracted to
     standalone files later without breaking references.

     Status values: Untested | In Progress | Reduced | Dismissed | Fatal

     Dismissed = the concern turned out to be a false alarm; continue the loop.
     Fatal     = the approach cannot resolve this uncertainty favorably →
                 abort. Return to INIT with a note on why the approach failed.

     Priority order (Step 2 selection):
     High risk + Low effort  → do first
     High risk + High effort → do second
     Medium risk + Low effort → do third
     Low risk → deprioritize

     ANTI-PATTERN CHECK (hard stops — do not proceed if any apply):
     - If you can't list 2 that could each independently kill the idea → go back to exploration.
       Count doesn't matter; independent lethality does.
     - If they all say "Low risk", or items look like padding → stop. Name what could
       actually kill this. "Things that could each independently invalidate the approach"
       is the bar, not "things that are vaguely uncertain."
     - If effort-to-test is "High" for all of them → look for cheaper proxies. -->

| ID          | Uncertainty                        | Risk                | Effort to test      | Status   |
| ----------- | ---------------------------------- | ------------------- | ------------------- | -------- |
| UNC-XXX-001 | _What could go wrong or be false?_ | High / Medium / Low | Low / Medium / High | Untested |
| UNC-XXX-002 |                                    |                     |                     | Untested |

<!-- Add more rows as needed. Minimum 2 items that could each independently invalidate the approach. -->

## Selected Uncertainty

<!-- Which single uncertainty does this hypothesis target?
     Pick the one with the most risk reduced per effort.
     One hypothesis → one uncertainty. -->

**Target:** UNC-XXX-NNN — _description_

**Why this one first:** _Why is this the highest-value uncertainty to resolve now?_

## Belief

_We believe that ..._

<!-- Scope this to the selected uncertainty. If the belief is broader than
     the uncertainty it targets, it's too broad. Narrow it. -->

## Why We Think This

<!-- Data, observation, user feedback, anecdote, expert opinion, gut feeling — be honest about the source. -->

## What Changes If We're Right

<!-- Observable outcome that improves. If nothing measurable changes, reconsider whether this is worth testing. -->

## Falsification Signal

<!-- What result would make this hypothesis unlikely or wrong? Be explicit.
     Vague falsification ("it doesn't work") is not a falsification signal. -->

## Why a Positive Result Is Not Trivial

<!-- What would a skeptic say about a confirming result? What alternative explanation
     would still be consistent with the evidence? This prevents "user clicked = validated." -->

## Alternative Hypothesis

<!-- What else could explain the same problem? State a real competitor, not a strawman.
     If you can't name one, you may be anchored. Keep looking. -->

## Smallest Possible Test

<!-- The cheapest way to confirm or reject. State the method AND what result constitutes
     confirmation vs rejection. Include a concrete sample size (e.g. "10 items", "5 requests").
     This should be a probe, not a feature. -->

- Method:
- Sample size:
- Confirms if:
- Rejects if:

## Time to Evidence

<!-- How quickly can we get signal? (hours / days / weeks)
     Prefer a worse test sooner over a perfect test later. -->

## Confidence Before Testing

_Low / Medium / High — and why._

## Validation Plan

_Broader test plan if the Smallest Possible Test is just the first step — what sequence of evidence would fully validate or falsify this?_

## Stories Derived From This Hypothesis

- _(none yet — add ST-\* links as stories are created)_

## Result

<!-- Fill in after each probe. Update the uncertainty table above.

     After updating, decide:
     - Continue discovery (select next uncertainty, repeat micro-loop)
     - Exit to delivery (discovery exit contract met) -->

- Status: Confirmed / Rejected / Inconclusive
- What was observed:
- Uncertainty update: UNC-XXX-NNN status → Reduced / Dismissed / Fatal
- Decision: _continue discovery_ / _exit to delivery_ / _abort — return to INIT_
