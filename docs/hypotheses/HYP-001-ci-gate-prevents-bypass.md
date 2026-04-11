# HYP-001: A CI gate on PR traceability will prevent chain bypass

## Linked Initiative

- INIT-001: Teams skip the HYP→ST chain under delivery pressure

## Assumption

We believe that failing CI on PRs missing a `ST-*` reference will cause developers to complete the HYP→ST chain before merging — rather than finding workarounds — because the gate is low-friction to satisfy for legitimate work and high-friction to bypass without explicit intent.

## Smallest Possible Test

An integration test: run `check-pr-links.sh` with a set of canned PR bodies (with ST-\* link, without, with `[fast-lane]`) and assert exit codes. This is sufficient — it validates the gate behavior without needing a real GitHub repo or live PRs.

## Validation Method

1. Implement `check-pr-links.sh` and `check-story-links.sh` in a pilot repo
2. Run for 4–6 weeks across 10+ PRs
3. Observe: how many PRs are blocked? How many result in proper chain completion vs. workarounds?
4. Track: are HYP-\*.md documents being written, or are developers citing pre-existing ones?

## Falsification Condition

This hypothesis is falsified if:

- More than 30% of blocked PRs result in workarounds (empty ST files, fabricated links) rather than genuine chain completion
- Developers consistently report the gate as unreasonable overhead for legitimate fast-lane work
- The check produces more than 20% false positives on valid fast-lane PRs

## Confidence Before Testing

**Low.** The gate is technically straightforward but behavioral response to enforcement is unknown. Teams may comply superficially (creating hollow documents) rather than genuinely.

## Stories Derived From This Hypothesis

- ST-001: Implement check-pr-links.sh
- ST-002: Implement check-story-links.sh

## Status

- [x] Untested
- [ ] In progress
- [ ] Confirmed
- [ ] Falsified
