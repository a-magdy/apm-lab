# Part 3: Publish and share

> **Time:** ~20 minutes · [Back to overview](../README.md)

**Goal:** publish `team-skills` to GitHub, tag a release, and install it in a second, separate repo.

## 3.1 Publish the shared set

Open `apm.yml` first: `author:` was filled from your git config, so edit it if you do not want that public.

Before publishing, preview what a consumer would receive:

```bash
apm pack --dry-run --verbose
```

It lists the files it would bundle (agents, instructions, skills and a generated `plugin.json`). If a file you wrote is missing from this list, it is in the wrong folder: APM only collects from `.apm/skills/`, `.apm/agents/` and `.apm/instructions/` (and `.apm/prompts/`, `.apm/hooks/`). A license warning is normal; add `license: MIT` to `apm.yml` to silence it. `--dry-run` writes nothing.

Commit the manifest and the `.apm/` source only, never `git add .`. In a package repo the deployed folders are not published; consumers regenerate them by installing (see the table in Part 1.4).

```bash
cd ~/apm-work/team-skills
git rm --cached -q add.js 2>/dev/null || true   # unstage the demo file from Part 2.7
git add apm.yml .apm/ .gitignore
git status --short                              # staged ("A"): apm.yml, .apm/ files, .gitignore. "?? add.js" is fine: untracked, not committed
git commit -m "feat: initial team-skills package"
git remote add origin https://github.com/<your-handle>/team-skills.git
git push -u origin main
```

## 3.2 Tag a release

A tag is what lets consumers stay stable while you keep changing `main`.

```bash
git tag -a v1.0.0 -m "v1.0.0"
git push --tags
```

## 3.3 Install it in a second repo

Make a new, empty project. This stands in for any other team's repo.

```bash
cd ~/apm-work
mkdir consumer-test && cd consumer-test
git init
apm init -y
apm install <your-handle>/team-skills#v1.0.0 --target copilot
```

Pair option: use your partner's handle instead (their repo must be public), in a fresh folder such as `consumer-partner`, then swap.

Now look:

```bash
cat apm.yml          # the dependency is recorded
cat apm.lock.yaml    # pinned commit and hashes
ls .github/agents .github/instructions .agents/skills
```

This repo is empty, so give Copilot something to review first:

```bash
printf 'function add(a, b) { return a - b }\n' > add.js && git add add.js
```

Then open `consumer-test` in VS Code and repeat the three Copilot checks from Part 2.7. The same skill, agent and instruction now work in a repo that has none of your source files.

## 3.4 Prove the "one repo" story

> ⚠️ **Destructive.** Run this only in `consumer-test`, the disposable repo. In `team-skills` it would delete your deployed folders and you would have to reinstall them. The `if` below does nothing anywhere else.

Delete everything APM installed, then restore it from the manifest:

```bash
if [ "$(basename "$PWD")" = consumer-test ]; then
  rm -rf .github .agents apm_modules
  apm install --target copilot
  ls .github/agents
else
  echo "Wrong folder: cd to consumer-test first"
fi
```

This is the whole sharing story: `git clone` plus `apm install` reproduces the setup on any machine.

✅ **Checkpoint:** `"$LAB/scripts/check.sh" publish` passes in `team-skills` (remote and tag) and again in `consumer-test` (dependency and deployed files).

> **Package not found?** The repo is private or misspelled. Make it public. For a private repo, prefer `gh auth login`; if you must use a token, make it fine-grained, read-only and short-lived, and never put it in a file or commit it.

Next: [Part 4, Verify and secure](04-verify-and-secure.md)
