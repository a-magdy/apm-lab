# Part 2: Author a shared set

> **Time:** ~25 minutes · [Back to overview](../README.md)

**Goal:** write a skill, an agent and an instruction, deploy them with `apm install`, and see each one behave differently in Copilot.

## 2.1 Three primitives, three invocation models

| Primitive | Invoked by | Use it when |
|-----------|-----------|-------------|
| Skill | The model, automatically | Copilot should reach for a guide based on what you asked |
| Agent | You, by selecting it | You want a persona or role on demand |
| Instruction | A file glob | A rule should apply whenever matching files are touched |

## 2.2 Scaffold

Make a new project, separate from Part 1. This is your shared set.

```bash
cd ~/apm-work
mkdir team-skills && cd team-skills
git init -b main
apm init -y
mkdir -p .apm/skills/pr-description .apm/agents .apm/instructions
```

> **In a hurry?** Copy the finished files instead of typing them: `cp -R "$LAB/solution/.apm/." .apm/` then jump to step 2.6.

## 2.3 Write the skill

Create `.apm/skills/pr-description/SKILL.md`. Copilot reads the `description` to decide when to load it, so lead with the user's intent.

```markdown
---
name: pr-description
description: >-
  Use when the user asks for a pull-request description, a summary of
  uncommitted or staged changes, or release notes for a change.
---
# PR Description Skill

Produce these sections, in order:

## Summary
One sentence. What changes and why. No file lists.

## Changes
Bullets grouped by area (API, Tests, Docs). One bullet per logical change.

## Risk and rollback
Breaking changes, migrations, feature flags, and how to revert.

## Testing
Commands run and environments tested.
```

## 2.4 Write the agent

Create `.apm/agents/team-reviewer.agent.md`:

```markdown
---
name: team-reviewer
description: Senior reviewer that critiques diffs against team standards before a PR.
---
# Team Reviewer

You review a teammate's diff before it becomes a pull request.

Check in this order: correctness, test coverage of changed paths,
naming and clarity, new public surface area.

Group findings as Blocking, Should fix, Nit. Cite file and line.
End with one verdict: "Ready to ship", "Address blockers then ship",
or "Needs another pass". Point and explain; do not rewrite the code.
```

## 2.5 Write the instruction

Create `.apm/instructions/pr-conventions.instructions.md`:

```markdown
---
description: Tone and format rules for pull-request templates and changelogs.
applyTo: "**/PULL_REQUEST_TEMPLATE.md,**/CHANGELOG.md"
---
# PR and changelog conventions

- Write for the reviewer, not for the author. Say why, not only what.
- Present tense, one change per line ("Adds", "Fixes").
- Never paste secrets, tokens or internal hostnames into descriptions.
```

## 2.6 Deploy

```bash
apm install --target copilot
```

Expected: one agent into `.github/agents/`, one instruction into `.github/instructions/`, one skill into `.agents/skills/`.

## 2.7 Try them in Copilot

Create something to review and stage it:

```bash
printf 'function add(a, b) { return a - b }\n' > add.js
git add add.js
```

Open Copilot Chat in this folder. **Predict first:** of the three prompts below, which one needs you to name something explicitly, and which two work without naming anything? Then test.

1. Ask: `draft a PR description for my staged changes`. The skill should activate **without being named**.
2. Select the **team-reviewer** agent yourself (VS Code: the agent picker in Chat; Copilot CLI: `/agent`), then ask: `review my staged changes`. The agent runs because you summoned it.
3. Create a file named `CHANGELOG.md`, then ask Copilot to add an entry to it. The instruction applies because the file glob matched.

## 2.8 Make it yours

Change the skill to match your team's PR template, or make the agent check one rule you care about (for example, no secrets in diffs). Run `apm install --target copilot` again and repeat the test. If you rename the skill, `check.sh author` will report it missing; that is fine.

✅ **Checkpoint:** `"$LAB/scripts/check.sh" author` passes in `team-skills`, **and** all three Copilot trials in 2.7 behaved as described: the PR description follows your four headings, the reviewer ends with one of the three verdicts (and should spot the `a - b` bug), and the changelog entry follows your conventions. The script only proves files exist; the trials prove they work. In your own words: what decided *when* each primitive ran?

> **Skill did not fire?** Reword its `description` to include the exact phrases you typed, reinstall, and retry.

> **Where files land:** agents and instructions go to `.github/`, a Copilot-specific location. Skills go to `.agents/skills/`, a location several tools read.

Next: [Part 3, Publish and share](03-publish-and-share.md)
