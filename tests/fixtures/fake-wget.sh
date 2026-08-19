#!/bin/sh
# Fake wget: intercepts reviewdog install.sh download
# Supports both:
#   wget -O - -q URL | sh  (pipe form, output to stdout via -O -)
#   wget -O /tmp/file -q URL (file form, write to file)
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
    SCRIPT_DIR="$(dirname "$0")"
    INSTALL_SCRIPT="$SCRIPT_DIR/fake-install-reviewdog.sh"
    if [ -n "$out" ] && [ "$out" != "-" ]; then
      cat "$INSTALL_SCRIPT" > "$out"
    else
      cat "$INSTALL_SCRIPT"
    fi
    exit 0
    ;;
esac
# Fall through to real wget for other URLs
exec /usr/bin/wget "$@"
