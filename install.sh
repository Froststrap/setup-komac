#!/usr/bin/env bash
set -euo pipefail

version="${KOMAC_VERSION#v}"

if [ -z "$version" ]; then
  echo "setup-komac: version input is required" >&2
  exit 1
fi

case "$RUNNER_OS" in
  Linux) target="unknown-linux-gnu" ;;
  macOS) target="apple-darwin" ;;
  Windows) target="pc-windows-msvc" ;;
  *)
    echo "setup-komac: unsupported RUNNER_OS: $RUNNER_OS" >&2
    exit 1
    ;;
esac

case "$RUNNER_ARCH" in
  X64) arch="x86_64" ;;
  ARM64) arch="aarch64" ;;
  *)
    echo "setup-komac: unsupported RUNNER_ARCH: $RUNNER_ARCH" >&2
    exit 1
    ;;
esac

if [ "$RUNNER_OS" = "Windows" ]; then
  asset="komac-${version}-${arch}-${target}.exe"
else
  asset="komac-${version}-${arch}-${target}.tar.gz"
fi

base="https://github.com/russellbanks/Komac/releases/download/v${version}"

curl -fsSL --retry 3 "$base/$asset" -o "$RUNNER_TEMP/$asset"
curl -fsSL --retry 3 "$base/SHA256SUMS" -o "$RUNNER_TEMP/SHA256SUMS"

expected="$(tr -d '\r' < "$RUNNER_TEMP/SHA256SUMS" | awk -v name="$asset" '$2 == name || $2 == "*" name { print $1 }')"

if [ -z "$expected" ]; then
  echo "setup-komac: no checksum listed for $asset" >&2
  exit 1
fi

actual="$(sha256sum "$RUNNER_TEMP/$asset" | cut -d' ' -f1)"

if [ "$expected" != "$actual" ]; then
  echo "setup-komac: checksum mismatch for $asset" >&2
  echo "  expected: $expected" >&2
  echo "  actual:   $actual" >&2
  exit 1
fi

bin="$RUNNER_TEMP/komac"
mkdir -p "$bin"

if [ "$RUNNER_OS" = "Windows" ]; then
  mv "$RUNNER_TEMP/$asset" "$bin/komac.exe"
  path="$(cygpath -w "$bin")"
else
  tar -xzf "$RUNNER_TEMP/$asset" -C "$bin" komac
  path="$bin"
fi

echo "$path" >> "$GITHUB_PATH"
echo "setup-komac: installed komac $version to $bin"
