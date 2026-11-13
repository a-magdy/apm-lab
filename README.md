# Lab: APM and Sharing

> **Duration:** about 90 minutes (about 60 if you copy from `solution/` and skip the optional Copilot checks) · **Level:** Beginner to Intermediate · **Format:** self-service, hands-on

## Objective

A teammate writes a great Copilot skill. A month later it exists as five slightly different copies in five repos, and nobody knows which one is current.

APM (Agent Package Manager) is a dependency manager for agent configuration: skills, agents, prompts, instructions and MCP servers. You declare what you need in `apm.yml`, `apm install` deploys it where Copilot reads it, and a lockfile pins exact commits and content hashes.

In this lab you will:

1. Install a published package and see exactly which files APM writes
2. Author a small shared set: one skill, one agent and one instruction
3. Publish it to GitHub and install it in a **second repo**
4. Prove the install is reproducible and that hand-edits get caught

**Challenge:** publish a shared set, install it in a second repo, and pass `apm audit --ci` on the consumer side.

## Before you start

This lab **publishes a GitHub repository** (`team-skills`) under your account and installs from it. Public is simplest. Use a personal or sandbox account if your employer restricts public repos, and delete the repo afterwards if you like.

## Prerequisites

- A terminal and Git. **Windows: use Git Bash (or WSL) for the whole lab.** All commands are bash.
- A git identity. If `git config user.name` and `git config user.email` already print values, you are set. Otherwise set them for this lab only, inside each project folder, with `git config user.name "Your Name"` (no `--global`). The email appears in public commits, so GitHub's no-reply address is fine
- A GitHub account with Copilot access
- The [GitHub CLI](https://cli.github.com/), signed in. **This is required, even if you push over SSH:** APM uses this login for its GitHub lookups. Without it the lookups are anonymous, and GitHub rate-limits anonymous requests per network, which a room full of people can use up

  ```bash
  gh auth login          # required: APM uses this token for GitHub lookups
  gh auth setup-git      # lets git push over HTTPS with the same login
  gh auth status         # must say "Logged in to github.com"
  ```

- VS Code with GitHub Copilot Chat (the Copilot CLI works for most checks; Part 1 step 6 needs VS Code)
- An **empty** GitHub repository named `team-skills`: tick nothing (no README, no .gitignore, no license). Public is simplest; pair mode needs it public
- Network access to github.com

## What you'll build

```text
┌─────────────────────────────┐
│ <you>/team-skills           │   SHARED SET (the producer repo)
│                             │
│ apm.yml                     │   manifest
│ .apm/skills/pr-description  │   skill     (model reaches for it)
│ .apm/agents/team-reviewer   │   agent     (you select it)
│ .apm/instructions/pr-conv.. │   instruction (applies by file glob)
│                             │
│ tagged v1.0.0 ──────────────┼──┐
└─────────────────────────────┘  │ apm install <you>/team-skills#v1.0.0
                                 ▼
┌─────────────────────────────┐
│ consumer-test/              │   SECOND REPO (the consumer)
│                             │
│ apm.yml                     │   records the dependency
│ apm.lock.yaml               │   pinned commit + content hashes
│ .github/agents/             │   deployed for Copilot
│ .github/instructions/       │
│ .agents/skills/             │
└─────────────────────────────┘
```

### The full picture

This is APM in everyday use: write once, publish a tag, and many repos consume it, with CI as the gate. Each folder in the picture is a real one you create in this lab, and it lists the files it holds.

![Three steps. 1: the team-skills folder, the producer, holds apm.yml and a .apm folder with a skill, an agent and an instruction. 2: it is pushed and tagged v1.0.0 on GitHub. 3: the consumer-test folder installs it with apm install and holds apm.yml, apm.lock.yaml and the deployed .github and .agents folders. CI runs apm audit --ci.](docs/images/apm-full-picture.jpg)

<details>
<summary>Detailed version: what each repo commits, and the CI order</summary>

![Diagram of the lab repos. team-skills (producer) holds apm.yml and a .apm folder with a skill, an agent and an instruction. It is pushed to GitHub and tagged v1.0.0. consumer-test installs it with apm install and holds apm.yml, apm.lock.yaml and the deployed .github and .agents folders. CI runs apm audit --ci, then apm install --frozen.](docs/images/apm-repos.svg)

</details>

<details>
<summary>Text version of the same diagram</summary>

```text
┌─────────────────────────────┐
│ AUTHOR     team-skills      │   Part 2: you write it once
│   apm.yml                   │
│   .apm/skills/              │
│   .apm/agents/              │
│   .apm/instructions/        │
└──────────────┬──────────────┘
               │ git push, git tag v1.0.0       Part 3
               ▼
┌─────────────────────────────┐
│ GITHUB   <you>/team-skills  │   the shared source: v1.0.0, v1.1.0, ...
└──────┬───────────────┬──────┘   (optional: a marketplace repo indexes it
       │               │           by name, Stretch B)
       │ apm install <you>/team-skills#v1.0.0
       ▼               ▼
┌──────────────┐ ┌──────────────┐
│ repo A       │ │ repo B       │ ...  any number of repos
│ (Copilot)    │ │ (Claude Code)│      you build one: consumer-test
│ .github/     │ │ .claude/     │
│ .agents/     │ │              │      each one keeps its own
│ apm.lock.yaml│ │ apm.lock.yaml│      lockfile: exact commit + hashes
└──────┬───────┘ └──────┬───────┘
       └───────┬────────┘
               ▼ on every pull request          Part 4
┌─────────────────────────────┐
│ CI    apm audit --ci        │   catches hand-edits and hidden characters
│       apm install --frozen  │   then restores exactly what the lockfile says
└─────────────────────────────┘
```

</details>

## Get the lab and make a working folder

Keep the lab repo and your own work separate, so your projects never nest inside it.

```bash
git clone https://github.com/a-magdy/apm-lab ~/apm-lab
export LAB=~/apm-lab           # re-run this in every new terminal
mkdir -p ~/apm-work && cd ~/apm-work
```

All guides assume you create `hack-lab`, `team-skills` and `consumer-test` as siblings inside `~/apm-work`.

## Your path

| Part | Guide | What you do | Min |
|------|-------|-------------|-----|
| 1 | [Setup and consume](labs/01-setup-and-consume.md) | Install APM, install a published package, inspect the result | 20 |
| 2 | [Author a shared set](labs/02-author.md) | Write a skill, an agent and an instruction, then deploy them | 25 |
| 3 | [Publish and share](labs/03-publish-and-share.md) | Push, tag, and install into a second repo | 20 |
| 4 | [Verify and secure](labs/04-verify-and-secure.md) | Lockfile, `--frozen`, drift and hidden-character detection with `apm audit` | 15 |
| 5 | [Wrap-up and stretch](labs/05-wrap-up-and-stretch.md) | Version bump, marketplace, challenges | 10+ |

Every part has a **Goal**, steps and (except the wrap-up) a **Checkpoint**. Checkpoints can be verified with the helper script, run from the folder the checkpoint names:

```bash
"$LAB/scripts/check.sh" <setup|consume|author|publish|verify>
```

> Timing: the minutes above add up to about 90. Copying from `solution/` and skipping the optional Copilot checks brings it to about 60.

Stuck? See the [appendix](labs/appendix.md) for troubleshooting and a command cheat sheet. Behind? The finished package is in [`solution/`](solution/): run `cp -R "$LAB/solution/.apm/." .apm/` inside your `team-skills` folder (after `mkdir -p .apm`).

## Prefer a web view?

The repo ships a small viewer (`index.html`) that renders these guides with a sidebar and progress tracking. It has to be served over HTTP, and it loads its scripts from a CDN, so it needs internet access:

```bash
cd "$LAB" && python3 -m http.server 8000   # then open http://localhost:8000
```

## Working in pairs

Work solo through Part 2. In Part 3, swap GitHub handles with a partner and install their package into a **fresh folder** (for example `consumer-partner`), because two packages with the same file names overwrite each other.

> **APM moves fast.** Commands were verified against APM 0.35.1. If output differs from this guide, check the [official docs](https://microsoft.github.io/apm/).
