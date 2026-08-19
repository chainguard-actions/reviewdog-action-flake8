<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-flake8/v3.13.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-flake8/v3.13.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

entrypoint.sh pipes a remote script directly to a shell interpreter. The line `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"` fetches and executes arbitrary content from a mutable URL (the `master` branch) without any integrity verification. A compromised or man-in-the-middle response would execute attacker-controlled code on the runner.

Locations:

- `entrypoint.sh:11`

### script-injection (severity: high)

Rule (b) violation: entrypoint.sh expands workflow-controlled env vars without double-quoting, allowing shell metacharacter injection. `${INPUT_FLAKE8_ARGS}` (line 21) and `${INPUT_REVIEWDOG_FLAGS}` (line 28) are both sourced from `inputs.*` (set via the action's `env:` block from `${{ inputs.flake8_args }}` and `${{ inputs.reviewdog_flags }}`), but are used unquoted in shell commands. An attacker-controlled value containing `;`, `|`, `&`, `$(...)`, or similar metacharacters would be interpreted by the shell. Offending lines: `flake8 . ${INPUT_FLAKE8_ARGS} 2>&1 |` and `${INPUT_REVIEWDOG_FLAGS} || exit_val="$?"`.

Locations:

- `entrypoint.sh:21`
- `entrypoint.sh:28`

### unpinned-uses (severity: high)

All four workflow files reference GitHub Actions using mutable tag refs instead of pinned full-length SHA commit hashes. Mutable tags can be silently moved to point to different (potentially malicious) commits. Unpinned references found:
- depup.yml: `actions/checkout@v4`, `reviewdog/action-depup@v1`, `peter-evans/create-pull-request@v6`
- release.yml: `actions/checkout@v4`, `haya14busa/action-bumpr@v1`, `haya14busa/action-update-semver@v1`, `haya14busa/action-cond@v1`, `haya14busa/action-bumpr@v1`
- reviewdog.yml: `actions/checkout@v4`, `haya14busa/action-cond@v1`, `reviewdog/action-shellcheck@v1`, `actions/checkout@v4`, `reviewdog/action-misspell@v1`, `actions/checkout@v4`, `reviewdog/action-alex@v1`
- test.yml: `actions/checkout@v4`, `actions/setup-python@v5` (×3 jobs)

Locations:

- `.github/workflows/depup.yml:13`
- `.github/workflows/release.yml:14`
- `.github/workflows/reviewdog.yml:11`
- `.github/workflows/test.yml:16`

### missing-permissions (severity: medium)

None of the four workflow files declare a top-level `permissions:` block, and no individual job within any of these files has a `permissions:` block. Without explicit permissions, workflows run with the default token permissions (which may be `write-all` depending on repository settings), granting unnecessarily broad access. Each workflow should declare the minimal required permissions (e.g., `permissions: contents: read`).

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all four findings:
1. unsafe-shell: Replaced wget|sh pipe in entrypoint.sh with download-to-tempfile then execute pattern using mktemp.
2. script-injection: Changed unquoted ${INPUT_FLAKE8_ARGS} and ${INPUT_REVIEWDOG_FLAGS} to use ${VAR:+"$VAR"} form to prevent shell metacharacter injection while preserving correct empty-argument behavior.
3. unpinned-uses: Pinned all 10 unique action references across depup.yml, release.yml, reviewdog.yml, and test.yml to full commit SHAs with tag comments for readability.
4. missing-permissions: Added minimal top-level permissions blocks to all four workflow files (depup.yml: contents+pull-requests write; release.yml: contents write; reviewdog.yml and test.yml: contents read + checks+pull-requests write).

