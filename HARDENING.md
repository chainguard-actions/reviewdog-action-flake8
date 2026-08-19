<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-flake8/v3.15.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-flake8/v3.15.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh downloads a remote install script and pipes it directly to `sh` without first saving it to a file for inspection. Pattern: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`. Even though the URL is pinned to a specific commit SHA, piping remote content directly to a shell interpreter is an unsafe pattern that bypasses any opportunity to verify the script before execution.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b) violation: Two unquoted shell variable expansions of untrusted inputs appear in entrypoint.sh. (1) `flake8 . ${INPUT_FLAKE8_ARGS} 2>&1` — INPUT_FLAKE8_ARGS is set from `inputs.flake8_args` (a caller-controlled value) and is expanded unquoted, allowing shell metacharacter injection (`;`, `|`, `&`, `$(...)`, etc.). The `# shellcheck disable=SC2086` comment acknowledges the unquoted expansion. (2) `${INPUT_REVIEWDOG_FLAGS}` — similarly unquoted, set from `inputs.reviewdog_flags`. Both must be double-quoted: `"${INPUT_FLAKE8_ARGS}"` and `"${INPUT_REVIEWDOG_FLAGS}"` (or use an array if word-splitting is intentional).

Locations:

- `entrypoint.sh:22`
- `entrypoint.sh:30`

### missing-permissions (severity: medium)

None of the four workflow files declare a `permissions:` key at the top level or at the job level. Without explicit permissions, workflows run with the repository's default token permissions, which may be overly broad (e.g., write access to contents, pull-requests, etc.). Each workflow should declare minimal required permissions. Affected files: depup.yml, release.yml, reviewdog.yml, test.yml.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

1. unsafe-shell (entrypoint.sh:13): Replaced `wget ... | sh` pipe pattern with: download script to /tmp/reviewdog-install.sh, execute it separately, then remove it. 2. script-injection (entrypoint.sh:22,30): Replaced unquoted ${INPUT_FLAKE8_ARGS} and ${INPUT_REVIEWDOG_FLAGS} with bash arrays (`read -ra flake8_args <<< "${INPUT_FLAKE8_ARGS}"` and `read -ra reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"`), expanded as `"${flake8_args[@]}"` and `"${reviewdog_flags[@]}"`. Removed the shellcheck disable comment. 3. missing-permissions: Added top-level `permissions:` blocks to all 4 workflow files: depup.yml (contents: write, pull-requests: write), release.yml (contents: write, pull-requests: write), reviewdog.yml (contents: read, checks: write, pull-requests: write), test.yml (contents: read, checks: write, pull-requests: write).

