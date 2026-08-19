#!/bin/sh
# Fake reviewdog install script
# Usage: sh fake-reviewdog-install.sh -b <bindir> [version]
# Installs a fake reviewdog binary at <bindir>/reviewdog

BINDIR="/tmp"
while [ $# -gt 0 ]; do
  case "$1" in
    -b)
      BINDIR="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

cat > "${BINDIR}/reviewdog" << 'REVIEWDOG_EOF'
#!/bin/sh
# Fake reviewdog binary for testing
FAIL_LEVEL="none"
FAIL_ON_ERROR="false"
for arg in "$@"; do
  case "$prev" in
    -fail-level=*) ;;
    *) ;;
  esac
  case "$arg" in
    -fail-level=none) FAIL_LEVEL="none" ;;
    -fail-level=any) FAIL_LEVEL="any" ;;
    -fail-level=info) FAIL_LEVEL="info" ;;
    -fail-level=warning) FAIL_LEVEL="warning" ;;
    -fail-level=error) FAIL_LEVEL="error" ;;
    -fail-on-error=true) FAIL_ON_ERROR="true" ;;
  esac
  prev="$arg"
done

# Read stdin (flake8 output)
INPUT="$(cat)"

echo "[fake-reviewdog] fail-level=$FAIL_LEVEL fail-on-error=$FAIL_ON_ERROR"
if [ -n "$INPUT" ]; then
  echo "[fake-reviewdog] Found issues:"
  echo "$INPUT"
  if [ "$FAIL_LEVEL" != "none" ] || [ "$FAIL_ON_ERROR" = "true" ]; then
    echo "[fake-reviewdog] Exiting with failure due to issues found"
    exit 1
  fi
fi
echo "[fake-reviewdog] Done"
exit 0
REVIEWDOG_EOF

chmod +x "${BINDIR}/reviewdog"
echo "Installed fake reviewdog to ${BINDIR}/reviewdog"
