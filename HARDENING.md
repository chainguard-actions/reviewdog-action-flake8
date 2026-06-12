<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-flake8/v3.15.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-flake8/v3.15.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh downloads a remote install script from a mutable `master` branch URL and pipes it directly to `sh` without first saving it to a file for inspection. This allows a compromised or tampered upstream script to execute arbitrary code on the runner. Offending line: `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"`

Locations:

- `entrypoint.sh:13`

### script-injection (severity: high)

Sub-rule (b): Two env vars holding workflow-controllable input values are expanded unquoted inside shell commands in entrypoint.sh, allowing shell metacharacter injection.

1. `${INPUT_FLAKE8_ARGS}` (sourced from `inputs.flake8_args`) is used unquoted in: `flake8 . ${INPUT_FLAKE8_ARGS} 2>&1 |` (line 24). A shellcheck-disable comment even acknowledges this unquoted expansion.

2. `${INPUT_REVIEWDOG_FLAGS}` (sourced from `inputs.reviewdog_flags`) is used unquoted in: `    ${INPUT_REVIEWDOG_FLAGS} || exit_val="$?"` (line 31).

An attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) can break out of the intended command and execute arbitrary code.

Locations:

- `entrypoint.sh:24`
- `entrypoint.sh:31`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed entrypoint.sh:
1. unsafe-shell (line 13): Replaced `wget ... | sh -s -- ...` with a safe pattern: download install.sh to a mktemp file, execute it with sh, then remove it. This prevents a compromised upstream script from executing arbitrary code via the pipe.
2. script-injection (lines 24, 31): Replaced unquoted expansions of ${INPUT_FLAKE8_ARGS} and ${INPUT_REVIEWDOG_FLAGS} with bash arrays using `read -ra`. Each value is split into an array and expanded as `"${array[@]+"${array[@]}"}"` (safe for empty arrays under set -u), ensuring shell metacharacters in user-controlled inputs are not interpreted by the shell.

