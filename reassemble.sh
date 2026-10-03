#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR"

OUTPUT=${1:-athena-src-20261003.tar.gz.enc}
TEMP_OUTPUT="${OUTPUT}.partial"
EXPECTED=$(tr -d '[:space:]' < chunks/FINAL-SHA256)

(
  cd chunks
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 -c SHA256SUMS
  else
    sha256sum -c SHA256SUMS
  fi
)

cat chunks/athena-src-20261003.tar.gz.enc.part-* > "$TEMP_OUTPUT"

if command -v shasum >/dev/null 2>&1; then
  ACTUAL=$(shasum -a 256 "$TEMP_OUTPUT" | awk '{print $1}')
else
  ACTUAL=$(sha256sum "$TEMP_OUTPUT" | awk '{print $1}')
fi

if [ "$ACTUAL" != "$EXPECTED" ]; then
  printf 'SHA-256 mismatch: expected %s, got %s\n' "$EXPECTED" "$ACTUAL" >&2
  rm -f "$TEMP_OUTPUT"
  exit 1
fi

mv "$TEMP_OUTPUT" "$OUTPUT"
printf 'Reassembled %s\nSHA-256 %s\n' "$OUTPUT" "$ACTUAL"
