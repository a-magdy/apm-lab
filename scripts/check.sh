#!/usr/bin/env bash
# Usage: check.sh <setup|consume|author|publish|verify>
# Run from inside the project folder the lab step tells you to use, calling it as "$LAB/scripts/check.sh".
# Prints PASS/FAIL per check and exits non-zero if any check fails.
set -euo pipefail

pass_count=0
fail_count=0

log_pass() { printf '  [PASS] %s\n' "$1"; pass_count=$((pass_count + 1)); }
log_fail() { printf '  [FAIL] %s\n        hint: %s\n' "$1" "$2"; fail_count=$((fail_count + 1)); }

# check <description> <hint> <command...>
check() {
  local desc="$1" hint="$2"
  shift 2
  if "$@" >/dev/null 2>&1; then log_pass "${desc}"; else log_fail "${desc}" "${hint}"; fi
}

has_file_in() { compgen -G "$1" >/dev/null; }
lock_mentions() { grep -q "$1" apm.lock.yaml; }
manifest_has_dep() { grep -Eq "^[[:space:]]+- .*$1" apm.yml; }
gitignored() { grep -q '^apm_modules/' .gitignore; }

check_setup() {
  check "apm is on PATH" "open a new shell, or run the PATH line the installer printed" command -v apm
  check "git is on PATH" "install git" command -v git
  check "apm --version runs" "reinstall APM; see labs/appendix.md" apm --version
  apm --version 2>/dev/null | sed 's/^/        version: /' || true
}

check_consume() {
  check "apm.yml exists" "run: apm init -y (inside hack-lab)" test -f apm.yml
  check "apm.lock.yaml exists" "run the apm install command from step 2" test -f apm.lock.yaml
  check "sample package is in the lockfile" "install microsoft/apm-sample-package#v1.0.0" lock_mentions apm-sample-package
  check "pinned to tag v1.0.0" "append #v1.0.0 to the package" lock_mentions "resolved_ref: v1.0.0"
  check "an agent was deployed to .github/agents/" "add --target copilot" has_file_in ".github/agents/*.agent.md"
  check "a skill was deployed to .agents/skills/" "add --target copilot" has_file_in ".agents/skills/*/SKILL.md"
}

check_author() {
  check "skill source exists" "create .apm/skills/pr-description/SKILL.md" test -f .apm/skills/pr-description/SKILL.md
  check "skill has a description" "add a description: field to the frontmatter" grep -q '^description:' .apm/skills/pr-description/SKILL.md
  check "agent source exists" "create .apm/agents/team-reviewer.agent.md" test -f .apm/agents/team-reviewer.agent.md
  check "instruction source exists" "create .apm/instructions/pr-conventions.instructions.md" test -f .apm/instructions/pr-conventions.instructions.md
  check "agent deployed to .github/agents/" "run: apm install --target copilot" test -f .github/agents/team-reviewer.agent.md
  check "skill deployed to .agents/skills/" "run: apm install --target copilot" test -f .agents/skills/pr-description/SKILL.md
  check "instruction deployed to .github/instructions/" "run: apm install --target copilot" test -f .github/instructions/pr-conventions.instructions.md
}

check_publish() {
  # Run in the AUTHOR folder (team-skills) for the git checks,
  # and in the CONSUMER folder (consumer-test) for the install checks.
  if [[ -d .apm ]]; then
    check "git remote 'origin' is set" "git remote add origin https://github.com/<you>/team-skills.git" git remote get-url origin
    check "tag v1.0.0 exists" "git tag -a v1.0.0 -m v1.0.0" git rev-parse -q --verify refs/tags/v1.0.0
    check "main is pushed" "git push -u origin main" bash -c 'git ls-remote origin refs/heads/main | grep -q refs/heads/main'
    check "tag v1.0.0 contains .apm/" "tag after committing .apm/" bash -c 'git ls-tree -r --name-only v1.0.0 | grep -q "^\.apm/"'
    check "tag v1.0.0 is pushed" "git push --tags" bash -c 'git ls-remote --tags origin | grep -q "refs/tags/v1.0.0"'
    check ".apm/ is committed" "git add apm.yml .apm/ && git commit" bash -c 'git ls-files --error-unmatch .apm >/dev/null'
  else
    check "consumer lists team-skills as a dependency" "run: apm install <you>/team-skills#v1.0.0 --target copilot" manifest_has_dep "team-skills"
    check "consumer lockfile pins team-skills" "re-run the install" lock_mentions "team-skills"
    check "pinned to tag v1.0.0" "install with #v1.0.0 appended" lock_mentions "resolved_ref: v1.0.0"
    check "team-reviewer agent arrived" "re-run the install with --target copilot" test -f .github/agents/team-reviewer.agent.md
    check "pr-description skill arrived" "re-run the install with --target copilot" test -f .agents/skills/pr-description/SKILL.md
  fi
}

check_verify() {
  # Read-only on purpose: never run an install here, it would silently repair drift
  # and hide the very thing apm audit is meant to catch.
  check "apm.lock.yaml exists (run this in consumer-test)" "run from consumer-test after the Part 3 install" test -f apm.lock.yaml
  check "apm.yml lists a dependency" "run this in consumer-test, not team-skills" grep -Eq '^[[:space:]]+- ' apm.yml
  check "apm_modules/ is gitignored" "apm adds it on install; check .gitignore" gitignored
  check "apm audit --ci reports no drift" "run: apm install --target copilot to restore edited files" apm audit --ci
}

case "${1:-}" in
  setup | consume | author | publish | verify)
    printf '\nChecking: %s\n' "$1"
    "check_$1"
    ;;
  *)
    printf 'Usage: %s <setup|consume|author|publish|verify>\n' "$0" >&2
    exit 2
    ;;
esac

printf '\n%d passed, %d failed\n' "${pass_count}" "${fail_count}"
[[ "${fail_count}" -eq 0 ]]
