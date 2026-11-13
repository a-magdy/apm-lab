# Part 5: Wrap-up and stretch

> **Time:** ~10 minutes, plus stretch · [Back to overview](../README.md)

## What you built

- ✅ A shared set with a skill, an agent and an instruction under `.apm/`
- ✅ A tagged release on GitHub
- ✅ A second repo that installs it with one command
- ✅ Lockfile restore and drift detection

## Taking it to a real team

```bash
apm audit --ci           # CI step 1: drift and security gate. Run it BEFORE any install
apm install --frozen     # CI step 2: fail if apm.yml and apm.lock.yaml disagree
apm outdated             # local: which dependencies have newer tags
apm marketplace check    # CI for marketplace authors: fail if an entry cannot resolve
```

> ⚠️ Order matters: any `apm install`, `--frozen` included, rewrites deployed files and would hide the drift that `apm audit --ci` is meant to catch (Part 4).

## Stretch A: ship a new version

1. In `team-skills`, add a rule to the instruction or tighten the agent.
2. Commit, then `git tag -a v1.1.0 -m "v1.1.0"` and `git push && git push --tags`.
3. In `consumer-test`, run `apm outdated`, then `apm install <your-handle>/team-skills#v1.1.0 --target copilot`.
4. Compare the old and new commit in `apm.lock.yaml`.

## Stretch B: publish through a marketplace

A marketplace is a second repo that indexes packages living elsewhere, so consumers install by short name instead of a git URL. You need a second empty GitHub repo, `team-marketplace`, and `team-skills` tagged `v1.0.0` (Part 3).

```bash
cd ~/apm-work
git clone https://github.com/<your-handle>/team-marketplace.git
cd team-marketplace
apm marketplace init --owner <your-handle> --name team-marketplace
apm marketplace package add <your-handle>/team-skills --name team-skills --version "^1.0.0"
```

1. Open `apm.yml`. `init` scaffolds a placeholder `example-package` entry: delete it, or validation fails.
2. Validate and build the index:

   ```bash
   apm marketplace check
   apm pack
   ```

   `check` resolves every entry against the remote. `pack` writes a `marketplace.json` that pins your range to a concrete tag and commit.
3. Commit `apm.yml` and the generated `marketplace.json`, push, then consume it from `consumer-test`:

   ```bash
   apm marketplace add <your-handle>/team-marketplace
   apm install team-skills@team-marketplace --target copilot
   ```

> ⚠️ Watch out: a `.gitignore` that excludes `*.json` will silently stop `marketplace.json` from being committed.

The Copilot Academy lab [APM in 60 Minutes](https://copilot-academy.github.io/labs/apm-in-60-minutes) walks through the same flow in more depth, plus the monorepo layout.

## Stretch C: declare an MCP server

In `consumer-test`, add an MCP server to `dependencies.mcp` in `apm.yml`, replacing the empty `mcp: []` that `apm init` wrote. This one needs no API key:

```yaml
dependencies:
  mcp:
    - io.github.ChromeDevTools/chrome-devtools-mcp
```

Keep the existing `apm:` list as it is. Run `apm install --target copilot`, then `git status` to see which file APM wrote for Copilot. APM blocks transitive MCP servers unless they are declared, which is why it is listed explicitly.

Find other servers with `apm mcp search <word>`. Many ask for a token or API key during install; do not paste a real secret into a lab repo.

## Challenges

1. **Break it on purpose.** Put the skill at the repo root instead of under `.apm/`, push, and reinstall in the consumer. What is missing, and did anything warn you?
2. **Two consumers, one source.** Install the same tag in a third repo with `--target claude`. What differs?
3. **Gate a pull request.** Write a GitHub Actions job that runs `apm audit --ci`, then `apm install --frozen`, in that order (see the warning above).

## Further reading

| Topic | Link |
|-------|------|
| Docs home | https://microsoft.github.io/apm/ |
| Quickstart | https://microsoft.github.io/apm/quickstart/ |
| Your first package | https://microsoft.github.io/apm/getting-started/first-package/ |
| Source | https://github.com/microsoft/apm |
