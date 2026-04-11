# INIT-001: Teams skip the HYP→ST chain under delivery pressure

## Problem Statement

When deadlines approach, developers merge PRs without linking a story, and stories get created without a hypothesis. The CLD chain exists on paper but is bypassed in practice. No automated gate prevents this.

## Who Experiences This

Any team using the CLD workflow on a shared repository. Most acute when:

- A "quick fix" gets merged before documentation is written
- A story is created to justify code that already exists
- A PR is opened directly from an issue without a hypothesis step

## Evidence It Exists

- This is the documented failure mode in `q3.md`: humans skip forcing functions under cognitive load
- The V-model critique in `q1.md` shows that every stage has a known bypass pattern
- No existing tool (GitHub, Jira, Linear) prevents merging without traceability links

## Assumptions

- [ ] Developers will bypass the chain if there is no automated gate
- [ ] A CI check that fails the PR is a sufficient deterrent for most bypasses
- [ ] The check can be implemented as a simple script without platform lock-in

## Success Signal

PRs that lack a ST-_ reference fail CI. PRs that reference a ST-_ that lacks a HYP-\* also fail CI. Fast-lane PRs that include explicit justification pass.

## Related Documents

- Hypotheses: HYP-001
