# GitHub Copilot Instructions — Closed-Loop Delivery (CLD)

See `AGENTS.md` for the full CLD behavioral contract. This file adds Copilot-specific context.

## Role Selection

Use the agent profiles in `.github/agents/` to select the right role for your task:

- **Discovery** (`.github/agents/discovery.agent.md`) — when starting from a vague idea or issue
- **Delivery** (`.github/agents/delivery.agent.md`) — when implementing an approved ST-\*.md
- **Review** (`.github/agents/review.agent.md`) — when reviewing a PR for traceability and test quality

If no agent is explicitly selected, default to asking which role is appropriate before proceeding.

## Copilot-Specific Constraints

- Do not suggest code edits until the current task is linked to a ST-\* document
- When suggesting a test, state which acceptance criterion from the ST-\* it covers
- When opening a PR, populate the PR template — do not leave sections empty
- `[fast-lane]` PRs still require an expected effect statement in the PR body
