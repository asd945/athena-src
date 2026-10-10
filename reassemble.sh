#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CHUNK_DIR="$ROOT/chunks"
OUTPUT=${1:-"$ROOT/athena-src-20261010.tar.gz.enc"}
TEMP_OUTPUT="${OUTPUT}.partial"
EXPECTED=$(tr -d '[:space:]' < "$CHUNK_DIR/FINAL-SHA256")

cleanup() {
  rm -f "$TEMP_OUTPUT"
}
trap cleanup EXIT HUP INT TERM

(
  cd "$CHUNK_DIR"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 -c SHA256SUMS
  else
    sha256sum -c SHA256SUMS
  fi
)

cat "$CHUNK_DIR"/athena-src-20261010.tar.gz.enc.part-* > "$TEMP_OUTPUT"

if command -v shasum >/dev/null 2>&1; then
  ACTUAL=$(shasum -a 256 "$TEMP_OUTPUT" | awk '{print $1}')
else
  ACTUAL=$(sha256sum "$TEMP_OUTPUT" | awk '{print $1}')
fi

if [ "$ACTUAL" != "$EXPECTED" ]; then
  printf 'SHA-256 mismatch: expected %s, got %s\n' "$EXPECTED" "$ACTUAL" >&2
  exit 1
fi

mv "$TEMP_OUTPUT" "$OUTPUT"
trap - EXIT HUP INT TERM
printf 'Reassembled %s\nSHA-256 %s\n' "$OUTPUT" "$ACTUAL"
