<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-flake8/v3.15.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-flake8/v3.15.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

All four workflow files reference third-party actions using mutable version tags instead of full 40-character SHA commit hashes. This exposes the workflow to supply-chain attacks where a tag could be silently moved to point to malicious code.

Failing references:
- depup.yml: actions/checkout@v4, reviewdog/action-depup@v1, peter-evans/create-pull-request@v6
- release.yml: actions/checkout@v4, haya14busa/action-bumpr@v1, haya14busa/action-update-semver@v1, haya14busa/action-cond@v1 (×2), haya14busa/action-bumpr@v1
- reviewdog.yml: actions/checkout@v4 (×3), haya14busa/action-cond@v1, reviewdog/action-shellcheck@v1, reviewdog/action-misspell@v1, reviewdog/action-alex@v1
- test.yml: actions/checkout@v4 (×3), actions/setup-python@v5 (×3)

Locations:

- `.github/workflows/depup.yml:13`
- `.github/workflows/depup.yml:14`
- `.github/workflows/depup.yml:21`
- `.github/workflows/release.yml:14`
- `.github/workflows/release.yml:22`
- `.github/workflows/release.yml:27`
- `.github/workflows/release.yml:32`
- `.github/workflows/release.yml:52`
- `.github/workflows/release.yml:54`
- `.github/workflows/reviewdog.yml:12`
- `.github/workflows/reviewdog.yml:13`
- `.github/workflows/reviewdog.yml:19`
- `.github/workflows/reviewdog.yml:27`
- `.github/workflows/reviewdog.yml:28`
- `.github/workflows/reviewdog.yml:36`
- `.github/workflows/reviewdog.yml:37`
- `.github/workflows/test.yml:10`
- `.github/workflows/test.yml:14`
- `.github/workflows/test.yml:32`
- `.github/workflows/test.yml:36`
- `.github/workflows/test.yml:54`
- `.github/workflows/test.yml:58`

### unsafe-shell (severity: high)

entrypoint.sh pipes a remote install script directly to a shell interpreter without first downloading and verifying it. The pattern `wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b /tmp "${REVIEWDOG_VERSION}"` fetches from a mutable URL (the `master` branch) and executes whatever content is returned, with no integrity check. A compromised or man-in-the-middle response would execute arbitrary code on the runner.

Locations:

- `entrypoint.sh:11`

### missing-permissions (severity: medium)

None of the four workflow files declare a top-level `permissions:` block, and no individual job within any of these files declares its own `permissions:` block. GitHub Actions defaults to the repository's configured default permissions (often `write-all` for older repositories), which violates the principle of least privilege. Each workflow should declare the minimal permissions required (e.g., `contents: read`).

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, unsafe-shell, missing-permissions

**Notes:**

Fixed all three findings:

1. unpinned-uses: Pinned all action references in depup.yml, release.yml, reviewdog.yml, and test.yml to full 40-character SHA hashes with version tag comments for readability. Actions pinned: actions/checkout@v4, actions/setup-python@v5, reviewdog/action-depup@v1, peter-evans/create-pull-request@v6, haya14busa/action-bumpr@v1, haya14busa/action-update-semver@v1, haya14busa/action-cond@v1, reviewdog/action-shellcheck@v1, reviewdog/action-misspell@v1, reviewdog/action-alex@v1.

2. unsafe-shell: Fixed entrypoint.sh to download the reviewdog install script to a temp file (via mktemp) first, then execute it separately, then remove it — eliminating the dangerous `wget ... | sh` pipe-from-internet pattern.

3. missing-permissions: Added top-level permissions blocks to all four workflow files with minimal required permissions (contents: write + pull-requests: write for depup/release; contents: read + checks: write + pull-requests: write for reviewdog/test).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed two script injection vulnerabilities in entrypoint.sh: (1) Line 27: replaced unquoted `${INPUT_FLAKE8_ARGS}` with a bash array - used `read -ra flake8_args <<< "${INPUT_FLAKE8_ARGS}"` then `"${flake8_args[@]}"` to safely split space-separated flags without allowing shell metacharacter injection. (2) Line 33: replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` with a bash array - used `read -ra reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"` then `"${reviewdog_flags[@]}"` for the same reason. The `# shellcheck disable=SC2086` comment was also removed since it's no longer needed. Both fixes preserve the intended functionality of passing multiple flags while preventing attackers from injecting shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) through caller-controlled inputs.

