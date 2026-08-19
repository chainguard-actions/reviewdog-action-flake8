#!/bin/sh
# Fake wget: intercepts reviewdog install URL and serves a canned install script.
# Supports both "wget -O - URL | sh" (stdout) and hardened "wget -O FILE URL" (file) forms.

out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -O|--output-document)
      out="$arg"
      ;;
  esac
  prev="$arg"
done

case "$*" in
  *reviewdog*)
    PAYLOAD="${GITHUB_WORKSPACE}/tests/fixtures/fake-reviewdog-install.sh"
    if [ -n "$out" ] && [ "$out" != "-" ]; then
      cat "$PAYLOAD" > "$out"
    else
      cat "$PAYLOAD"
    fi
    exit 0
    ;;
esac

# Fall through to real wget for other URLs
exec /usr/bin/wget "$@"
