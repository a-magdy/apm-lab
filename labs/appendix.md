# Appendix: troubleshooting and cheat sheet

[Back to overview](../README.md)

## Troubleshooting

| Symptom | Likely cause and fix |
|---------|----------------------|
| `apm: command not found` | Open a new shell, or run the `PATH` line the installer printed |
| `apm install` exits with code 2 | No harness detected. Add `--target copilot`, or set `targets: [copilot]` in `apm.yml`. `apm targets` shows what APM detects |
| Package not found | Repo is private or misspelled. Make it public, or run `gh auth login` so APM can read it with your login |
| Skill never activates | Reword the skill `description` to match the phrases you typed, then reinstall |
| Installed files not visible in Copilot | Open the project folder itself in VS Code, not its parent |
| `apm audit` exits 0 despite drift | Expected. Use `apm audit --ci` for a failing exit code |
| `apm install` prints `unpinned` | Add `#tag` or `#sha` to the install source |
| TLS or certificate errors | See the [SSL troubleshooting page](https://microsoft.github.io/apm/troubleshooting/ssl-issues/) |

## Cheat sheet

| Command | What it does |
|---------|--------------|
| `apm init -y` | Create `apm.yml` in the current folder |
| `apm install <owner>/<repo>[#tag] --target copilot` | Install a package and deploy for Copilot |
| `apm install --target copilot` | Deploy your own `.apm/` source and re-sync deployed files |
| `apm install --frozen` | Install strictly from the lockfile (CI) |
| `apm targets` | Show which tools APM detects here |
| `apm audit` / `apm audit --ci` | Diff deployed files against expected; `--ci` exits non-zero on drift |
| `apm outdated` | Show dependencies with newer matching tags |
| `apm update` | Refresh dependencies within declared ranges |
| `apm prune` | Remove cached packages no longer in `apm.yml` |
