#!/bin/sh
# Validate the basic training image build.
#
# Usage: ./scripts/check-lab.sh [build-dir]
#
# The default build directory is labs/build.

set -eu

here=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
build=${1:-"$here/build"}

if [ ! -d "$build" ]; then
    echo "Build directory not found: $build" >&2
    echo "Run './kas.sh build kas/qemu.yml' first." >&2
    exit 1
fi

manifest=$(find "$build/tmp/deploy/images" -name 'training-image-*.manifest' 2>/dev/null | head -n 1)
if [ -z "$manifest" ]; then
    echo "Training image manifest not found under $build/tmp/deploy/images" >&2
    exit 1
fi

grep -q '^hello ' "$manifest" || {
    echo "FAIL: hello package is missing from $manifest" >&2
    exit 1
}

grep -q '^training-info ' "$manifest" || {
    echo "FAIL: training-info package is missing from $manifest" >&2
    exit 1
}

grep -q '^training-service ' "$manifest" || {
    echo "FAIL: training-service package is missing from $manifest" >&2
    exit 1
}

grep -q 'meta-training' "$build/conf/bblayers.conf" || {
    echo "FAIL: meta-training is missing from bblayers.conf" >&2
    exit 1
}

echo "Lab check OK"
echo "  manifest: $manifest"
echo "  packages: hello, training-info, training-service"
echo "  layer:    meta-training"
