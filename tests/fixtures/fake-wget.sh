#!/bin/sh
# Fake wget: intercepts reviewdog install.sh downloads.
# Supports both "wget URL | sh" (stdout) and "wget -O FILE URL" (write to file).
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -O|--output-document) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *reviewdog*|*install.sh*)
    if [ -n "$out" ] && [ "$out" != "-" ]; then
      cat /tmp/fake-install-reviewdog.sh > "$out"
    else
      cat /tmp/fake-install-reviewdog.sh
    fi
    exit 0
    ;;
esac
exec /usr/bin/wget "$@"
