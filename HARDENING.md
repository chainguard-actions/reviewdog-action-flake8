<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-flake8/v3.13.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-flake8/v3.13.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh downloads a remote install script from GitHub's master branch and pipes it directly to `sh` without first saving it to a file for inspection. This allows a compromised or man-in-the-middle response to execute arbitrary code on the runner. Offending line: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Rule (b) violation: The shell variable `${INPUT_FLAKE8_ARGS}` (sourced from `inputs.flake8_args`, a user-controlled input) is expanded unquoted in the shell command `flake8 . ${INPUT_FLAKE8_ARGS}`. An attacker can supply shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to inject arbitrary commands. The variable must be double-quoted: `"${INPUT_FLAKE8_ARGS}"`.

Locations:

- `entrypoint.sh:24`

### script-injection (severity: high)

Rule (b) violation: The shell variable `${INPUT_REVIEWDOG_FLAGS}` (sourced from `inputs.reviewdog_flags`, a user-controlled input) is expanded unquoted at the end of the reviewdog invocation. An attacker can supply shell metacharacters to inject arbitrary commands. The variable must be double-quoted: `"${INPUT_REVIEWDOG_FLAGS}"`.

Locations:

- `entrypoint.sh:30`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed three findings in entrypoint.sh:
1. unsafe-shell (line 13): Replaced `wget ... | sh` pipe with a two-step approach: download the install script to /tmp/reviewdog_install.sh, execute it with `sh`, then remove it. This prevents arbitrary code execution from a compromised or MITM response.
2. script-injection (line 24): Double-quoted `${INPUT_FLAKE8_ARGS}` → `"${INPUT_FLAKE8_ARGS}"` to prevent shell metacharacter injection.
3. script-injection (line 30): Double-quoted `${INPUT_REVIEWDOG_FLAGS}` → `"${INPUT_REVIEWDOG_FLAGS}"` to prevent shell metacharacter injection.

