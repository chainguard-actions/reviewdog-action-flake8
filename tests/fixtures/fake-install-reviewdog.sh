#!/bin/sh
# Fake reviewdog install script
# Parses -b <bindir> and <version> arguments, installs a fake reviewdog binary
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

mkdir -p "$BINDIR"
cat > "$BINDIR/reviewdog" << 'REVIEWDOG_EOF'
#!/bin/sh
# Fake reviewdog binary: reads stdin, exits 0
cat > /dev/null
exit 0
REVIEWDOG_EOF
chmod +x "$BINDIR/reviewdog"
echo "Installed fake reviewdog to $BINDIR/reviewdog"
