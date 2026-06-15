<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-flake8/v3.15.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-flake8/v3.15.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh downloads a remote install script and pipes it directly to `sh` without first saving it to a file for inspection. The command `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"` executes whatever the remote server returns. Even though the URL is pinned to a commit SHA in the path, the content is still executed without verification, and any MITM or CDN compromise would result in arbitrary code execution on the runner.

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b) violation: `${INPUT_FLAKE8_ARGS}` is expanded unquoted in the shell command `flake8 . ${INPUT_FLAKE8_ARGS}`. This variable is set from `inputs.flake8_args` (a caller-controlled input) via the `env:` block in action.yml. Because it is unquoted, an attacker can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) through the `flake8_args` input to execute arbitrary commands. The shellcheck disable comment on the preceding line acknowledges but does not fix the issue.

Locations:

- `entrypoint.sh:22`

### script-injection (severity: high)

Rule (b) violation: `${INPUT_REVIEWDOG_FLAGS}` is expanded unquoted at the end of the reviewdog invocation (`${INPUT_REVIEWDOG_FLAGS} || exit_val="$?"`). This variable is set from `inputs.reviewdog_flags` (a caller-controlled input) via the `env:` block in action.yml. Because it is unquoted, an attacker can inject shell metacharacters through the `reviewdog_flags` input to execute arbitrary commands on the runner.

Locations:

- `entrypoint.sh:30`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed all three findings in entrypoint.sh:
1. unsafe-shell (line 13): Replaced `wget ... | sh` pipe with: download to a mktemp file, execute separately, then delete the temp file.
2. script-injection (line 22): Replaced unquoted `${INPUT_FLAKE8_ARGS}` with a bash array: `read -ra flake8_args <<< "${INPUT_FLAKE8_ARGS}"` and `"${flake8_args[@]}"`.
3. script-injection (line 30): Replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` with a bash array: `read -ra reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"` and `"${reviewdog_flags[@]}"`.

