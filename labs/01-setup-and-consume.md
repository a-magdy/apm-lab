# Part 1: Setup and consume a package

> **Time:** ~20 minutes · [Back to overview](../README.md)

**Goal:** get APM running, install someone else's package, and see exactly which files land for Copilot.

## 1.1 Install APM

macOS with Homebrew:

```bash
brew install apm
```

Linux or macOS without Homebrew (read the script first if you prefer):

```bash
curl -sSL https://aka.ms/apm-unix | sh
```

**Windows:** the only PowerShell step in this lab is the installer. Run it once in PowerShell, then close it and do everything else in **Git Bash**.

```powershell
irm https://aka.ms/apm-windows | iex
```

If `apm` is not found in Git Bash afterwards, install it with Python instead, from Git Bash:

```bash
pip install --user "apm-cli==0.35.1"
```

If `apm` is still not found, pip's user scripts folder is not on your `PATH`. Add it (and put the same line in `~/.bashrc` to keep it for new shells):

```bash
export PATH="$(cygpath -u "$(python -c 'import sysconfig; print(sysconfig.get_path("scripts", sysconfig.get_preferred_scheme("user")))')"):$PATH"
```

Open a new shell, then:

```bash
apm --version
```

> **Container or Codespace?** The installer can exit 0 with a broken binary. Always run `apm --version`. If it fails with a sqlite error, run `pip install --user "apm-cli==0.35.1"` instead.

✅ **Checkpoint:** `apm --version` prints a version. Note it down: version mismatches explain odd output.

## 1.2 Consume a package

Why bother? Without a package manager, a good skill gets copied into repo after repo, the copies drift, and nobody knows which one is current. APM treats agent context like any other dependency. Try it.

1. Create a project. `apm init` writes one file, the manifest.

   ```bash
   mkdir hack-lab && cd hack-lab
   git init
   apm init -y
   ```

2. **Predict first:** which folders will appear after an install, and which file will record exactly what was installed? Write your guess down, then run:

   ```bash
   apm install microsoft/apm-sample-package#v1.0.0 --target copilot
   ```

   A fresh project has no Copilot marker yet, so you must name the target.

3. Read the output. You should see prompts, an agent and an instruction going into `.github/`, and a skill into `.agents/skills/`. The package's own dependency installs in the same pass.

   > **A deliberate teaching example:** you will see `1 dependency unpinned`. The sample package depends on a repo without a tag, so what you get tracks a moving branch. Keep that in mind for Part 4.

4. Look at what changed. How close was your guess?

   ```bash
   cat apm.yml
   cat apm.lock.yaml
   ls .github/prompts .github/agents .github/instructions .agents/skills
   apm targets
   ```

5. Inspect the installed package's metadata, then see which tags the remote offers.

   ```bash
   apm view microsoft/apm-sample-package
   apm view microsoft/apm-sample-package versions
   ```

   > `apm list` is not for this: it lists *scripts* from `apm.yml`, so it prints "No scripts found" here.

6. Open the folder in VS Code, start Copilot Chat, type `/`, and run one of the installed prompts against any file. (Copilot CLI does not expose prompt files as slash commands; skip this step there, but note that skills do show up as slash commands in the CLI.)

## 1.3 What just happened

Three things do all the work:

| Item | Written by | Purpose |
|------|-----------|---------|
| `apm.yml` | you | The manifest: your dependencies and targets |
| `apm.lock.yaml` | APM | Exact commits and SHA-256 hashes of everything deployed |
| `apm_modules/` | APM | Package cache. Gitignored, rebuildable |

`apm install` does the same five things every time:

```text
apm install
  1. Resolve    turn "owner/repo#v1.0.0" into an exact commit
  2. Policy     check apm-policy.yml, if your org ships one
  3. Scan       reject hidden-Unicode tricks in package content
  4. Integrate  copy files into the folders each detected tool reads
  5. Lockfile   record commits and content hashes
```

Package authors write one layout (`.apm/`). APM rewrites files into the folders each tool reads:

| Author writes | Copilot reads |
|---------------|---------------|
| `.apm/skills/x/SKILL.md` | `.agents/skills/x/SKILL.md` |
| `.apm/agents/x.agent.md` | `.github/agents/x.agent.md` |
| `.apm/instructions/x.instructions.md` | `.github/instructions/x.instructions.md` |

## 1.4 What to commit

The rule differs for the two kinds of repo you will meet in this lab:

| Path | Consumer repo | Package repo (you publish it) | Why |
|------|:---:|:---:|-----|
| `apm.yml` | yes | yes | The manifest |
| `apm.lock.yaml` | yes | no | Reproducible installs for consumers; a package has no dependencies to pin |
| `.apm/` | n/a | yes | The source you author |
| `.github/`, `.agents/` | yes | no | A consumer's teammates get the context on clone, even without APM. In a package repo these are regenerated copies |
| `apm_modules/` | no | no | Rebuildable cache, already in `.gitignore` |

✅ **Checkpoint:** run `"$LAB/scripts/check.sh" consume` in `hack-lab`, and answer:

- Which file records the exact commit installed?
- Why did step 2 need `--target copilot`?
- Why does a consumer repo commit the deployed folders as well as the manifest?

<details>
<summary>Answers</summary>

1. `apm.lock.yaml`.
2. APM found no harness marker to auto-detect.
3. So teammates get the context on clone, with no APM required.

</details>

**Optional:** in a second folder run the same install with `--target claude` and compare. The same package lands in `.claude/`. Warnings about dropped frontmatter keys are expected; they show APM adapting files per tool.

Next: [Part 2, Author a shared set](02-author.md)
